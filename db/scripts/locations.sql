-- -- CITIES AND NEIGHBOURHOODS
-- INSERT INTO Locations  (name, location_type, description, latitude, longitude)
-- SELECT r.region_name, region_type, region_name_long, latitude, longitude 
-- FROM ean_regions r
-- JOIN ean_region_coordinates c on r.id = c.ean_region_id
-- WHERE coalesce(r.sub_class,'') != 'city' 
-- ORDER BY region_type 
-- 
-- -- POINTS OF INTEREST - BY CITY
INSERT INTO Locations  (landmark,  city, latitude, longitude)
SELECT r.region_name, r.parent_region_name, latitude, longitude 
FROM ean_regions r
JOIN ean_points_of_interest_coordinates c on r.id = c.ean_region_id
WHERE parent_region_type = 'City'
ORDER BY region_type 

-- -- POINTS OF INTEREST - BY REGION
INSERT INTO Locations  (landmark,  region, latitude, longitude)
SELECT r.region_name, r.parent_region_name, latitude, longitude 
FROM ean_regions r
JOIN ean_points_of_interest_coordinates c on r.id = c.ean_region_id
WHERE parent_region_type = 'Province (State)'
ORDER BY region_type 

-- -- POINTS OF INTEREST - BY COUNTRY
INSERT INTO Locations  (landmark,  country, latitude, longitude)
SELECT r.region_name, r.parent_region_name, latitude, longitude 
FROM ean_regions r
JOIN ean_points_of_interest_coordinates c on r.id = c.ean_region_id
WHERE parent_region_type = 'Country'
ORDER BY region_type 

-- CITIES REGION COUNTRIES
INSERT INTO Locations (city, city_id, region, region_id, country, country_code, language_code, longitude, latitude)
select b.city, b.city_id,  r.name, r.region_id, cn.name, cn.country_code, r.language_code, c.longitude, c.latitude
from region_booking_hotel_lookups rh
join booking_hotels b on rh.booking_hotel_id = b.id
join regions r on r.region_id = rh.region_id and r.language_code = 'en'
join cities c on c.id = b.city_id
join countries cn on cn.country_code = r.country_code and r.language_code = cn.language_code
group by b.city, b.city_id,  r.region_id, r.name, cn.name, cn.country_code, r.language_code, c.longitude, c.latitude

--REGIONS COUNTRIES
INSERT INTO Locations ( region, region_id, country, country_code, language_code)
select  r.name, r.region_id, cn.name, cn.country_code, r.language_code
from regions r 
join countries cn on cn.country_code = r.country_code and r.language_code = cn.language_code
where r.language_code = 'en'
group by r.region_id, r.name, cn.name, cn.country_code, r.language_code

--COUNTRIES
INSERT INTO Locations ( country, country_code, language_code)
select cn.name, cn.country_code, language_code
from countries cn 
group by cn.name, cn.country_code, cn.language_code

INSERT INTO locations (city, city_id, country, country_code, language_code, longitude, latitude)
SELECT c.name, c.id, cn.name, cn.country_code, cn.language_code, c.longitude, c.latitude
from cities c
join countries cn on cn.country_code = c.country_code 
left join locations l on l.city_id = c.id
where l.id is null and cn.language_code = 'en'
group by c.name, c.id,  cn.name, cn.country_code, cn.language_code, c.longitude, c.latitude

select * from countries limit 1
select * from locations where city ilike 'Las Vegas'

select * from cities where id =-2152917

select * from cities where name ilike 'Washington%'


select * from regions limit 1


select * from locations where region is null and city is null

select * from locations where city is null


select * from locations where slug in(
select slug from locations
group by slug
having count(*) > 1
)
order by slug