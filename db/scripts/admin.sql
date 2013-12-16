create extension pg_trgm
create extension postgis

--   ALTER TABLE etb_cities  ADD COLUMN geog geography(Point,4326);
-- 	ALTER TABLE booking_hotels  ADD COLUMN geog geography(Point,4326);
-- 	ALTER TABLE hotels  ADD COLUMN geog geography(Point,4326);
--  	ALTER TABLE ean_hotels  ADD COLUMN geog geography(Point,4326);
--   ALTER TABLE locations  ADD COLUMN geog geography(Point,4326);
-- 	UPDATE booking_hotels SET geog = ST_MakePoint(longitude, latitude);
-- 	UPDATE ean_hotels SET geog = ST_MakePoint(longitude, latitude);
-- 	UPDATE hotels SET geog = ST_MakePoint(longitude, latitude) where hotels.geog is null;
-- CREATE INDEX ON booking_hotels USING GIST (geog);
-- CREATE INDEX ON hotels USING GIST (geog);
-- CREATE INDEX ON ean_hotels USING GIST (geog);

-- 
-- INSERT INTO hotels (name, address, city, postal_code, country_code, longitude, latitude, star_rating, check_in_time, check_out_time, low_rate, high_rate, property_currency, booking_hotel_id)
-- SELECT name, address, city, zip, country_code, longitude, latitude, classification, check_in_from, check_out_to, minrate, maxrate, currencycode, id
-- from booking_hotels

-- ALTER TABLE locations  ADD COLUMN geog geography(Point,4326);
-- UPDATE locations SET geog = ST_MakePoint(longitude, latitude);
-- UPDATE hotels SET geog = ST_MakePoint(longitude, latitude);
-- SELECT e.name, h.name, ST_Distance(e.geog, h.geog) AS dist_m
-- FROM ean_hotels e
-- JOIN booking_hotels h ON ST_DWithin(e.geog, h.geog, 5, true)



-- PHASE 1 - MATCH ON NAME / CITY / POSTAL CODE
UPDATE hotels SET ean_hotel_id =  matched_hotel.ean_hotel_id
FROM ( 
	SELECT DISTINCT e.id AS ean_hotel_id, h.id AS hotel_id 
	FROM ean_hotels e 
	JOIN hotels h ON e.name = h.name AND e.city = h.city AND e.postal_code ILIKE h.postal_code 
	WHERE h.ean_hotel_id IS NULL  ) as matched_hotel
 WHERE matched_hotel.hotel_id = hotels.id and hotels.ean_hotel_id IS NULL


-- -- PHASE 2 - MATCH ON NAME / CITY / STATE + POSTAL CODE
UPDATE hotels SET ean_hotel_id =  matched_hotel.ean_hotel_id
FROM ( 
	SELECT DISTINCT e.id AS ean_hotel_id, h.id AS hotel_id 
	FROM ean_hotels e 
	JOIN hotels h ON e.name = h.name AND e.city = h.city AND  (e.state_province || ' ' || e.postal_code) ILIKE h.postal_code 
	WHERE h.ean_hotel_id IS NULL  ) as matched_hotel
 WHERE matched_hotel.hotel_id = hotels.id and hotels.ean_hotel_id IS NULL

-- PHASE 3 - MATCH EXACT WITH SAME NAME AND WITHIN 100m
UPDATE hotels SET ean_hotel_id =  matched_hotel.ean_hotel_id
FROM ( 
	SELECT DISTINCT e.id AS ean_hotel_id, h.id AS hotel_id 
	FROM ean_hotels e
	JOIN hotels h ON ST_DWithin(e.geog, h.geog, 100) AND e.name ILIKE h.name 
	WHERE h.ean_hotel_id IS NULL  ) AS matched_hotel
WHERE matched_hotel.hotel_id = hotels.id and hotels.ean_hotel_id IS NULL

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

-- PHASE 7 - MATCH FUZZY NAME ((0.85 correlation) AND WITHIN 1000
UPDATE hotels SET ean_hotel_id =  matched_hotel.ean_hotel_id
FROM ( 
	SELECT DISTINCT e.id AS ean_hotel_id, h.id AS hotel_id 
	FROM ean_hotels e
	JOIN hotels h ON ST_DWithin(e.geog, h.geog, 1000) 
		WHERE h.ean_hotel_id IS NULL 
		AND similarity(h.name, e.name) >0.85 ) AS matched_hotel
WHERE matched_hotel.hotel_id = hotels.id and hotels.ean_hotel_id IS NULL


-- PHASE 8 - MATCH FUZZY NAME ((0.75 correlation) AND WITHIN 2000
UPDATE hotels SET ean_hotel_id =  matched_hotel.ean_hotel_id
FROM ( 
	SELECT DISTINCT e.id AS ean_hotel_id, h.id AS hotel_id 
	FROM ean_hotels e
	JOIN hotels h ON ST_DWithin(e.geog, h.geog, 2000) 
		WHERE h.ean_hotel_id IS NULL 
		AND similarity(h.name, e.name) >0.75 ) AS matched_hotel
WHERE matched_hotel.hotel_id = hotels.id and hotels.ean_hotel_id IS NULL


-- PHASE 9 - INSERT all non-matched EAN hotels
INSERT INTO hotels (name, address, city, postal_code, country_code, longitude, latitude, star_rating, check_in_time, check_out_time, low_rate, high_rate, property_currency, ean_hotel_id)
select * from (
	SELECT e.name, COALESCE(e.address1,'') || COALESCE(COALESCE(', ' || address2, '') || COALESCE(', ' || e.state_province),'') , e.city, e.postal_code, 
	e.country, e.longitude, e.latitude, e.star_rating, e.check_in_time, e.check_out_time, e.high_rate, e.low_rate, e.property_currency, e.id
	from ean_hotels e
	left join hotels h on h.ean_hotel_id = e.id
	where h.id is null) as main

-- IMAGE INSERTS
-- TRUNCATE TABLE hotel_images
-- insert into hotel_images (hotel_id, caption, url, width, height, byte_size, thumbnail_url, default_image)
-- select h.id, i.caption, i.url, i.width, i.height, i.byte_size, i.thumbnail_url, i.default_image from hotels h
-- join ean_hotel_images i on i.ean_hotel_id = h.ean_hotel_id


-- 
-- SELECT DISTINCT e.id, e.name AS ean_hotel_id, h.name, e.city, h.city, e.postal_code, h.postal_code AS hotel_id 
-- 	FROM ean_hotels e
-- 	JOIN hotels h ON ST_DWithin(e.geog, h.geog, 1000) AND e.name ILIKE h.name 
-- 	WHERE h.ean_hotel_id IS NULL 

select count(*) from ean_hotels e
left join hotels h on h.ean_hotel_id = e.id
where h.id is null
select * from hotels where ean_hotel_id in (291041) or id = 309515

select * from hotels where name = 'La Viareggina'

select * from ean_hotels where name ='Haus Sonnheim'

select count(*) from hotels where ean_hotel_id is not null
select count(*) from ean_hotels
select * from ean_hotels limit 1


	  
-- Try 500 metres with 0.6 5 (
-- then 1000 metres with 0.9 (20,000)
-- 
select e.id, e.name AS ean_name, h.name, e.city, h.city, e.postal_code, h.postal_code, ST_Distance(e.geog, h.geog) as dist
from ean_hotels e
join hotels h on ST_DWithin(e.geog, h.geog, 5000) and similarity(h.name, e.name) >0.75
where h.ean_hotel_id is null

select e.id, h.id, e.name AS ean_hotel_id, h.name, e.city, h.city, e.postal_code, h.postal_code, ST_Distance(e.geog, h.geog) as dist
from ean_hotels e
join hotels h on ST_DWithin(e.geog, h.geog, 1000, false) and similarity(h.name, e.name) >0.94
where h.ean_hotel_id is null and e.id in (399495,270446)

update hotels set ranking = expedia.sequence_number * -1
from
(select id, sequence_number from ean_hotels) expedia
where expedia.id = hotels.ean_hotel_id and hotels.ean_hotel_id is not null and booking_hotel_id is null


select * from hotels where id = 309515

select set_limit(0.9)
select show_limit()


UPDATE hotels h SET state_province = br.name
FROM
(SELECT booking_hotel_id, r.name FROM region_booking_hotel_lookups l
  JOIN regions r on r.region_id = l.region_id
  WHERE r.language_code = 'en') as br
  WHERE  h.booking_hotel_id = br.booking_hotel_id AND state_province IS NULL
 limit (100)

