-- ALTER TABLE hotels  ADD COLUMN geog geography(Point,4326);
-- 
-- UPDATE hotels SET geog = ST_MakePoint(longitude, latitude);
-- 
-- CREATE INDEX ON hotels USING GIST (geog);
-- 
-- INSERT INTO hotels (name, address, city, postal_code, country_code, longitude, latitude, star_rating, check_in_time, check_out_time, low_rate, high_rate, property_currency, booking_hotel_id)
-- SELECT name, address, city, zip, country_code, longitude, latitude, classification, check_in_from, check_out_to, minrate, maxrate, currencycode, id
-- from booking_hotels
-- SELECT e.name, h.name, ST_Distance(e.geog, h.geog) AS dist_m
-- FROM ean_hotels e
-- JOIN booking_hotels h ON ST_DWithin(e.geog, h.geog, 5, true)

-- 2200 at 3 metres
-- invalid IDs 423087, 368629
SELECT e.name, e.state_province, e.postal_code, h.postal_code, ST_Distance(e.geog, h.geog) as dist
FROM ean_hotels e 
JOIN hotels h ON e.name = h.name AND e.city = h.city AND (e.state_province || ' ' || e.postal_code) ILIKE h.postal_code 
WHERE e.id NOT IN (423087, 368629, 380507,392693,326467)  AND h.ean_hotel_id is null


-- PHASE 1 - MATCH ON NAME / CITY / POSTAL CODE
-- UPDATE hotels SET ean_hotel_id =  matched_hotel.ean_hotel_id
-- FROM ( 
-- 	SELECT DISTINCT e.id AS ean_hotel_id, h.id AS hotel_id 
-- 	FROM ean_hotels e 
-- 	JOIN hotels h ON e.name = h.name AND e.city = h.city AND e.postal_code ILIKE h.postal_code 
-- 	WHERE h.ean_hotel_id IS NULL AND e.id NOT IN (423087, 368629, 380507,392693,326467, 441410,118931,279820, 404028,339341) ) as matched_hotel
--  WHERE matched_hotel.hotel_id = hotels.id and hotels.ean_hotel_id IS NULL


-- -- PHASE 2 - MATCH ON NAME / CITY / STATE + POSTAL CODE
-- UPDATE hotels SET ean_hotel_id =  matched_hotel.ean_hotel_id
-- FROM ( 
-- 	SELECT DISTINCT e.id AS ean_hotel_id, h.id AS hotel_id 
-- 	FROM ean_hotels e 
-- 	JOIN hotels h ON e.name = h.name AND e.city = h.city AND  (e.state_province || ' ' || e.postal_code) ILIKE h.postal_code 
-- 	WHERE h.ean_hotel_id IS NULL AND e.id NOT IN (423087, 368629, 380507,392693,326467, 441410,118931,279820, 404028,339341) ) as matched_hotel
--  WHERE matched_hotel.hotel_id = hotels.id and hotels.ean_hotel_id IS NULL

-- PHASE 3 - MATCH EXACTWITH SAME NAME AND WITHIN 20m
-- UPDATE hotels SET ean_hotel_id =  matched_hotel.ean_hotel_id
-- FROM ( 
-- 	SELECT DISTINCT e.id AS ean_hotel_id, h.id AS hotel_id 
-- 	FROM ean_hotels e
-- 	JOIN hotels h ON ST_DWithin(e.geog, h.geog, 100) AND e.name ILIKE h.name 
-- 	WHERE h.ean_hotel_id IS NULL AND e.id NOT IN (423087, 368629, 380507,392693,326467, 441410,118931,279820, 139887, 404028,339341) ) AS matched_hotel
-- WHERE matched_hotel.hotel_id = hotels.id and hotels.ean_hotel_id IS NULL

-- PHASE 4 - MATCH FUZZY NAME ((0.9 correlation) AND WITHIN 500m
UPDATE hotels SET ean_hotel_id =  matched_hotel.ean_hotel_id
FROM ( 
	SELECT DISTINCT e.id AS ean_hotel_id, h.id AS hotel_id 
	FROM ean_hotels e
	JOIN hotels h ON ST_DWithin(e.geog, h.geog, 500) 
		WHERE h.ean_hotel_id IS NULL 
		AND similarity(h.name, e.name) >0.9 ) AS matched_hotel
WHERE matched_hotel.hotel_id = hotels.id and hotels.ean_hotel_id IS NULL

-- PHASE 5 - MATCH FUZZY NAME ((0.9 correlation) AND WITHIN 1km
UPDATE hotels SET ean_hotel_id =  matched_hotel.ean_hotel_id
FROM ( 
	SELECT DISTINCT e.id AS ean_hotel_id, h.id AS hotel_id 
	FROM ean_hotels e
	JOIN hotels h ON ST_DWithin(e.geog, h.geog, 1000) 
		WHERE h.ean_hotel_id IS NULL 
		AND similarity(h.name, e.name) >0.9 ) AS matched_hotel
WHERE matched_hotel.hotel_id = hotels.id and hotels.ean_hotel_id IS NULL

-- PHASE 6 - MATCH FUZZY NAME ((0.8 correlation) AND WITHIN 500
UPDATE hotels SET ean_hotel_id =  matched_hotel.ean_hotel_id
FROM ( 
	SELECT DISTINCT e.id AS ean_hotel_id, h.id AS hotel_id 
	FROM ean_hotels e
	JOIN hotels h ON ST_DWithin(e.geog, h.geog,500) 
		WHERE h.ean_hotel_id IS NULL 
		AND similarity(h.name, e.name) >0.8 ) AS matched_hotel
WHERE matched_hotel.hotel_id = hotels.id and hotels.ean_hotel_id IS NULL

-- PHASE 7 - MATCH FUZZY NAME ((0.8 correlation) AND WITHIN 500
UPDATE hotels SET ean_hotel_id =  matched_hotel.ean_hotel_id
FROM ( 
	SELECT DISTINCT e.id AS ean_hotel_id, h.id AS hotel_id 
	FROM ean_hotels e
	JOIN hotels h ON ST_DWithin(e.geog, h.geog, 1000) 
		WHERE h.ean_hotel_id IS NULL 
		AND similarity(h.name, e.name) >0.85 ) AS matched_hotel
WHERE matched_hotel.hotel_id = hotels.id and hotels.ean_hotel_id IS NULL

-- 
-- SELECT DISTINCT e.id, e.name AS ean_hotel_id, h.name, e.city, h.city, e.postal_code, h.postal_code AS hotel_id 
-- 	FROM ean_hotels e
-- 	JOIN hotels h ON ST_DWithin(e.geog, h.geog, 1000) AND e.name ILIKE h.name 
-- 	WHERE h.ean_hotel_id IS NULL 

select * from ean_hotels where id = 291041
select * from hotels where ean_hotel_id in (291041) or id = 309515

select * from hotels where name = 'La Viareggina'

select * from ean_hotels where name ='Haus Sonnheim'

select count(*) from hotels where ean_hotel_id is not null

select * from ean_hotels limit 1

-- Try 500 metres with 0.6 5 (
-- then 1000 metres with 0.9 (20,000)
-- 
select e.id, e.name AS ean_name, h.name, e.city, h.city, e.postal_code, h.postal_code, ST_Distance(e.geog, h.geog) as dist
from ean_hotels e
join hotels h on ST_DWithin(e.geog, h.geog, 1000) and similarity(h.name, e.name) >0.85
where h.ean_hotel_id is null

select e.id, h.id, e.name AS ean_hotel_id, h.name, e.city, h.city, e.postal_code, h.postal_code, ST_Distance(e.geog, h.geog) as dist
from ean_hotels e
join hotels h on ST_DWithin(e.geog, h.geog, 1000, false) and similarity(h.name, e.name) >0.94
where h.ean_hotel_id is null and e.id in (399495,270446)


select * from hotels where id = 309515

select set_limit(0.9)
select show_limit()