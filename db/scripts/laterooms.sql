
DROP INDEX index_hotels_on_laterooms_hotel_id;
UPDATE hotels SET laterooms_hotel_id = NULL WHERE laterooms_hotel_id IS NOT NULL

--Add Geography
-- ALTER TABLE late_rooms_hotels ADD COLUMN geog geography(Point,4326);

--Update Geography
-- UPDATE late_rooms_hotels SET geog = CAST(ST_SetSRID(ST_Point(longitude, latitude),4326) As geography)

--Index Geography
-- CREATE INDEX late_rooms_hotels_geog_idx
--   ON late_rooms_hotels
--   USING gist(geog);

-- PHASE 1 - MATCH ON NAME / CITY / POSTAL CODE
-- Updated 15882
--select * from late_rooms_hotels limit 100
UPDATE Public.Hotels AS H
SET laterooms_hotel_id = LR.Id, laterooms_url = LR.url
FROM
	Public.late_rooms_hotels AS LR
WHERE
	LOWER(H.postal_code) = LOWER(LR.postcode)
	AND COALESCE(H.postal_code,'') != ''
	AND LOWER(H.Name) = LOWER(LR.name);

--select * from hotels where lower(name) = 'accommodation delia'

-- -- PHASE 2 -  MATCH EXACT WITH SAME NAME AND WITHIN 100m
-- 3152
UPDATE Public.Hotels AS H
SET laterooms_hotel_id = LR.Id, laterooms_url = LR.url
FROM
	Public.late_rooms_hotels AS LR
WHERE
	LOWER(H.Name) = LOWER(LR.name)
	AND ST_DWithin(LR.geog, H.Geog, 100)
	AND H.laterooms_hotel_id IS NULL;	

 -- PHASE 3 - MATCH FUZZY NAME ((0.9 correlation) AND WITHIN 500m
-- 4628
UPDATE hotels 
SET 
	laterooms_hotel_id =  matched_hotel.laterooms_hotel_id, 
	laterooms_url = matched_hotel.url
FROM ( 
	SELECT DISTINCT e.id AS laterooms_hotel_id, h.id AS hotel_id, e.url as url
	FROM late_rooms_hotels e 
	JOIN hotels h ON ST_DWithin(e.geog, h.geog, 500) 
		WHERE h.laterooms_hotel_id IS NULL 
		AND similarity(lower(h.name), lower(e.name)) >0.9 ) AS matched_hotel
WHERE matched_hotel.hotel_id = hotels.id and hotels.laterooms_hotel_id IS NULL;

 -- PHASE 4 - MATCH FUZZY NAME ((0.9 correlation) AND WITHIN 1km
 -- 442
 UPDATE Public.Hotels AS H
SET laterooms_hotel_id = LR.Id, laterooms_url = LR.url
FROM
	Public.late_rooms_hotels AS LR
WHERE
	H.laterooms_hotel_id IS NULL
	AND ST_DWithin(LR.geog, H.geog, 1000) 
	AND SIMILARITY(H.name, LR.name) >0.9;
	
	
 -- PHASE 5 - MATCH FUZZY NAME ((0.8 correlation) AND WITHIN 500
 -- 2295
UPDATE Public.Hotels AS H
SET laterooms_hotel_id = LR.Id, laterooms_url = LR.url
FROM
	Public.late_rooms_hotels AS LR
WHERE
	H.laterooms_hotel_id IS NULL
	AND ST_DWithin(LR.geog, H.geog, 500) 
	AND SIMILARITY(H.name, LR.name) >0.8;
	

 -- PHASE 6 - MATCH FUZZY NAME ((0.85 correlation) AND WITHIN 1000
 --  70
UPDATE Public.Hotels AS H
SET laterooms_hotel_id = LR.Id, laterooms_url = LR.url
FROM
	Public.late_rooms_hotels AS LR
WHERE
	H.laterooms_hotel_id IS NULL
	AND ST_DWithin(LR.geog, H.geog, 1000) 
	AND SIMILARITY(H.name, LR.name) >0.85;
	
-- PHASE 7 - MATCH FUZZY NAME ((0.75 correlation) AND WITHIN 2000
--2694
UPDATE Public.Hotels AS H
SET laterooms_hotel_id = LR.Id, laterooms_url = LR.url
FROM
	Public.late_rooms_hotels AS LR
WHERE
	H.laterooms_hotel_id IS NULL
	AND ST_DWithin(LR.geog, H.geog, 2000) 
	AND SIMILARITY(H.name, LR.name) >0.75;

-- PHASE 8 - MATCH FUZZY NAME ((0.75 correlation) AND WITHIN 10000
--  693
UPDATE Public.Hotels AS H
SET laterooms_hotel_id = LR.Id, laterooms_url = LR.url
FROM
	Public.late_rooms_hotels AS LR
WHERE
	H.laterooms_hotel_id IS NULL
	AND ST_DWithin(LR.geog, H.geog, 10000) 
	AND SIMILARITY(H.name, LR.name) >0.8;


DELETE FROM  hotels WHERE hotel_provider =  'laterooms';
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
laterooms_hotel_id, 
laterooms_user_rating, 
hotel_provider)
SELECT 
	lr.name as name, 
	lr.address1  as address, 
	lr.city as city, 
	county as state_province, 
	postcode as postal_code, 
	NULL as country_code,
	--lower(countryisocode) as country_code, 
	lr.longitude, 
	lr.latitude, 
	CASE left(lr.star_rating, 1) 
		WHEN 'N' THEN null 
		WHEN 'A' THEN null 
		WHEN 'B' THEN null 
		WHEN 'T' THEN null 
		ELSE CAST(left(lr.star_rating, 1) AS DOUBLE PRECISION) 
	END AS star_rating,
	lr.check_in_time, 
	lr.check_out_time, 
	CAST(price_from as double precision) as low_rate, 
	currency_code as property_currency, 
	lr.geog, 
	lr.description as description, 
	lr.id as laterooms_hotel_id,
	CAST(score_out_of_6 AS DOUBLE PRECISION) as lateroom_user_rating,
	'laterooms' AS hotel_provider
FROM late_rooms_hotels lr
LEFT JOIN hotels h1 ON h1.laterooms_hotel_id = lr.id
WHERE h1.id IS NULL;


CREATE  INDEX index_hotels_on_laterooms_hotel_id
  ON hotels
  USING btree
  (laterooms_hotel_id);



-- DROP TABLE late_rooms_hotel_images;

-- CREATE TABLE late_rooms_hotel_images
-- (
--   id serial NOT NULL,
--   laterooms_hotel_id integer,
--   image_url character varying(255),
--   default_image boolean,
--   CONSTRAINT laterooms_hotel_images_pkey PRIMARY KEY (id)
-- )
-- WITH (
--   OIDS=FALSE
-- );

-- 
TRUNCATE TABLE late_rooms_hotel_images
INSERT INTO late_rooms_hotel_images (laterooms_hotel_id, image_url, default_image)
 SELECT id, regexp_split_to_table(images, E';'), false 
 FROM late_rooms_hotels; 

INSERT INTO late_rooms_hotel_images (laterooms_hotel_id, image_url, default_image)
 SELECT id, image, true
 FROM late_rooms_hotels; 
 

CREATE  INDEX index_laterooms_hotel_id_on_late_rooms_hotel_images
  ON late_rooms_hotel_images
  USING btree
  (laterooms_hotel_id);
  
DELETE FROM hotel_images WHERE caption = 'LateRoomsHotel';

INSERT INTO hotel_images (hotel_id, caption, url, thumbnail_url,default_image)
SELECT t1.id, 'LateRoomsHotel', hi.image_url,hi.image_url, default_image
FROM late_rooms_hotel_images hi
JOIN
(SELECT h.id, laterooms_hotel_id FROM hotels h 
LEFT JOIN hotel_images i ON h.id = i.hotel_id
WHERE  i.id IS NULL AND  h.laterooms_hotel_id IS NOT NULL) as t1
ON t1.laterooms_hotel_id = hi.laterooms_hotel_id ;


UPDATE hotels
SET laterooms_url = t1.url
FROM (SELECT id, url FROM late_rooms_hotels lr) as t1
WHERE hotels.laterooms_hotel_id = t1.id

-- AMENITIES
TRUNCATE TABLE late_rooms_amenities
INSERT INTO late_rooms_amenities (laterooms_hotel_id,amenity)
 SELECT id, regexp_split_to_table(facilities, E';') 
 FROM late_rooms_hotels; 

 CREATE TABLE late_rooms_facilities
(
  id serial NOT NULL,
  description text,
  flag integer,
  CONSTRAINT late_rooms_facilities_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

INSERT INTO late_rooms_facilities (description)
 select distinct amenity from late_rooms_amenities

 
UPDATE late_rooms_facilities SET flag = 1 WHERE lower(description) like '%wi-fi%'
UPDATE late_rooms_facilities SET flag = 4 WHERE description = 'Childrens Facilities - Outdoor' OR description = 'Babysitting services' OR description = 'Cots available' OR description = 'Childrens Facilities - Indoor'
UPDATE late_rooms_facilities SET flag = 8 WHERE lower(description) like '%parking%';
UPDATE late_rooms_facilities SET flag = 16 WHERE description = 'Gymnasium' OR description = 'Fitness Centre' OR description = 'Aerobics Studio' 
UPDATE late_rooms_facilities SET flag = 64 WHERE description = 'Hotel Non-Smoking Throughout' OR description = 'Smoking allowed in public areas'
UPDATE late_rooms_facilities SET flag =128 WHERE description = 'Pets Allowed'
UPDATE late_rooms_facilities SET flag = 256 WHERE lower(description) like '%pool%' 
UPDATE late_rooms_facilities SET flag = 512 WHERE lower(description) like '%restaurant%';


UPDATE hotels 
SET laterooms_user_rating = CAST(T1.score_out_of_6 AS DOUBLE PRECISION) 
FROM
 (SELECT id, score_out_of_6 FROM late_rooms_hotels WHERE CAST(score_out_of_6 AS DOUBLE PRECISION) > 0) AS t1
 WHERE hotels.laterooms_hotel_id = T1.id