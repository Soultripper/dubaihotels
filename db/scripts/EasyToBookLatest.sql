-- Index: hotels_etb_hotel_id_idx
-- DROP INDEX etb_hotel_id_idx;
UPDATE hotels SET  etb_hotel_id = NULL WHERE etb_hotel_id IS NOT NULL;

--Add Geography
-- ALTER TABLE etb_hotels ADD COLUMN geog geography(Point,4326);

--Update Geography
-- UPDATE etb_hotels SET geog = CAST(ST_SetSRID(ST_Point(longitude, latitude),4326) As geography)

--Index Geography
-- CREATE INDEX etb_hotels_geog_idx
--   ON etb_hotels
--   USING gist(geog);
 
-- PHASE 1 - MATCH ON NAME / CITY / POSTAL CODE
-- Updated 95803
UPDATE Public.Hotels AS H
SET etb_hotel_Id = ETB.Id
FROM
	Public.etb_hotels AS ETB
JOIN etb_cities city on city.id = ETB.city_id
JOIN etb_countries c on c.id = city.country_id
WHERE
	LOWER(H.country_code) = LOWER(c.country_iso)
	AND LOWER(H.postal_code) = LOWER(ETB.zipcode)
	AND COALESCE(H.postal_code,'') != ''
	AND LOWER(H.Name) = LOWER(ETB.name);

-- -- PHASE 2 -  MATCH EXACT WITH SAME NAME AND WITHIN 100m
-- 22073
UPDATE Public.Hotels AS H
SET etb_hotel_id = ETB.Id
FROM
	Public.etb_hotels AS ETB
WHERE
	LOWER(H.Name) = LOWER(ETB.name)
	AND ST_DWithin(ETB.geog, H.Geog, 100)
	AND H.etb_hotel_id IS NULL;	

 -- PHASE 3 - MATCH FUZZY NAME ((0.9 correlation) AND WITHIN 500m
-- 14335
UPDATE hotels SET etb_hotel_id =  matched_hotel.etb_hotel_id
FROM ( 
	SELECT DISTINCT e.id AS etb_hotel_id, h.id AS hotel_id 
	FROM etb_hotels e 
	JOIN hotels h ON ST_DWithin(e.geog, h.geog, 500) 
		WHERE h.etb_hotel_id IS NULL 
		AND similarity(lower(h.name), lower(e.name)) >0.9 ) AS matched_hotel
WHERE matched_hotel.hotel_id = hotels.id and hotels.etb_hotel_id IS NULL;

 -- PHASE 4 - MATCH FUZZY NAME ((0.9 correlation) AND WITHIN 1km
 -- 
 UPDATE Public.Hotels AS H
SET etb_hotel_id = ETB.Id
FROM
	Public.etb_hotels AS ETB
WHERE
	H.etb_hotel_id IS NULL
	AND ST_DWithin(ETB.geog, H.geog, 1000) 
	AND SIMILARITY(H.name, ETB.name) >0.9;
	
	
 -- PHASE 5 - MATCH FUZZY NAME ((0.8 correlation) AND WITHIN 500
 -- 
UPDATE Public.Hotels AS H
SET etb_hotel_id = ETB.Id
FROM
	Public.etb_hotels AS ETB
WHERE
	H.etb_hotel_id IS NULL
	AND ST_DWithin(ETB.geog, H.geog, 500) 
	AND SIMILARITY(H.name, ETB.name) >0.8;
	

 -- PHASE 6 - MATCH FUZZY NAME ((0.85 correlation) AND WITHIN 1000
 --  
UPDATE Public.Hotels AS H
SET etb_hotel_id = ETB.Id
FROM
	Public.etb_hotels AS ETB
WHERE
	H.etb_hotel_id IS NULL
	AND ST_DWithin(ETB.geog, H.geog, 1000) 
	AND SIMILARITY(H.name, ETB.name) >0.85;
	
-- PHASE 7 - MATCH FUZZY NAME ((0.75 correlation) AND WITHIN 2000
--
UPDATE Public.Hotels AS H
SET etb_hotel_id = ETB.Id
FROM
	Public.etb_hotels AS ETB
WHERE
	H.etb_hotel_id IS NULL
	AND ST_DWithin(ETB.geog, H.geog, 2000) 
	AND SIMILARITY(H.name, ETB.name) >0.75;

-- PHASE 8 - MATCH FUZZY NAME ((0.75 correlation) AND WITHIN 10000
--  
UPDATE Public.Hotels AS H
SET etb_hotel_id = ETB.Id
FROM
	Public.etb_hotels AS ETB
WHERE
	H.etb_hotel_id IS NULL
	AND ST_DWithin(ETB.geog, H.geog, 10000) 
	AND SIMILARITY(H.name, ETB.name) >0.8;

DELETE FROM hotels WHERE hotel_provider = 'easytobook';

-- PHASE 8 - INSERT all non-matched EAN hotels
-- 10714
INSERT INTO hotels (
name, 
address, 
city, 
state_province, 
postal_code, 
country_code, 
longitude, 
latitude, 
star_rating, 
check_in_time, 
check_out_time, 
low_rate, 
property_currency, 
geog, 
description, 
etb_hotel_id, 
etb_user_rating, 
hotel_provider)
SELECT 
	ETB.name as name, 
	ETB.address  as address, 
	cities.city_name as city, 
	cities.province_name as state_province, 
	zipcode as postal_code, 
	countries.country_iso as country_code,
	--lower(countryisocode) as country_code, 
	ETB.longitude, 
	ETB.latitude, 
	CAST(stars AS DOUBLE PRECISION) AS star_rating,
	ETB.check_in,
	ETB.check_out, 
	CAST(min_price as double precision) as low_rate, 
	NULL as property_currency, 
	ETB.geog, 
	descs.description as description, 
	ETB.id as etb_hotel_id,
	CAST(hotel_review_score AS DOUBLE PRECISION) as etb_user_rating,
	'easytobook' AS hotel_provider
FROM etb_hotels ETB
JOIN etb_cities cities on cities.id = ETB.city_id
JOIN etb_countries countries on countries.id = cities.country_id
JOIN etb_hotel_descriptions descs on descs.etb_hotel_id = ETB.id
LEFT JOIN hotels h1 ON h1.etb_hotel_id = ETB.id
WHERE h1.id IS NULL;

CREATE INDEX etb_hotel_id_idx
  ON hotels
  USING btree
  (etb_hotel_id);
  

DELETE FROM hotel_images where caption = 'EasyToBookHotel';

INSERT INTO hotel_images (hotel_id, caption, url, thumbnail_url,default_image)
SELECT t1.id, 'EasyToBookHotel', hi.image,hi.image, false
FROM etb_hotel_images hi
JOIN
(SELECT h.id, etb_hotel_id FROM hotels h 
LEFT JOIN hotel_images i ON h.id = i.hotel_id
WHERE  i.id IS NULL AND  h.etb_hotel_id IS NOT NULL) as t1
ON t1.etb_hotel_id = hi.etb_hotel_id ;

-- AMENITIES
ALTER TABLE etb_facilities ADD COLUMN flag integer;
ALTER TABLE etb_hotel_facilities ADD COLUMN amenities text;
ALTER TABLE etb_hotel_facilities ADD COLUMN flag integer;

INSERT INTO etb_facilities VALUES (586, 'Pets allowed', 128)
INSERT INTO etb_facilities VALUES (587,'Parking (free)', 8)
INSERT INTO etb_facilities VALUES (588,'Spa Tub', 1024)
INSERT INTO etb_facilities VALUES (590,'Free Parking (limited)', 8)
INSERT INTO etb_facilities VALUES (591,'Free parking', 8)


UPDATE etb_facilities SET flag = 4 WHERE description = 'BabySitting' OR description = 'Child Care Program' or description like 'Children''s%';
UPDATE etb_facilities SET flag = 8 WHERE lower(description) like '%parking%';
UPDATE etb_facilities SET flag = 16 WHERE description = 'Aerobics' OR description = 'Aquagym' OR description = 'Fitness center' OR description = 'Health club' OR description = 'Yoga/Pilates';
UPDATE etb_facilities SET flag = 64 WHERE description = 'Entire property is non-smoking' OR description = 'Smoking not allowed (fines apply)' OR description = 'Smoking area';
UPDATE etb_facilities SET flag = 256 WHERE lower(description) like '%pool%' OR description = 'Water sports';
UPDATE etb_facilities SET flag = 512 WHERE lower(description) like '%restaurant%';
UPDATE etb_facilities SET flag = 1024 WHERE  description = 'Spa/wellness center';

UPDATE hotels SET amenities = t.flag
FROM (SELECT id, flag FROM etb_hotel_facilities WHERE flag IS NOT NULL) AS t
WHERE hotels.etb_hotel_id = t.id AND hotels.amenities IS NULL
