DROP INDEX agoda_hotel_id_idx;
UPDATE hotels SET  agoda_hotel_id = NULL WHERE agoda_hotel_id IS NOT NULL

--Add Geography
--ALTER TABLE agoda_hotels ADD COLUMN geog geography(Point,4326);

--Update Geography
-- UPDATE agoda_hotels SET geog = CAST(ST_SetSRID(ST_Point(longitude, latitude),4326) As geography)
-- WHERE (longitude BETWEEN -180 AND 180)
-- AND (Latitude BETWEEN -90 AND 90);
--Except for hotel 445969 which has an invalid latitude :s

--Index Geography
-- CREATE INDEX agoda_hotels_geog_idx
--   ON agoda_hotels
--   USING gist(geog);

--86,090 to match


-- PHASE 1 - MATCH ON NAME / CITY / POSTAL CODE
-- Updated 14592

UPDATE Public.Hotels AS H
SET Agoda_Hotel_Id = AH.Id
FROM
	Public.Agoda_Hotels AS AH
WHERE
	LOWER(H.country_code) = LOWER(AH.countryISOCode)
	AND LOWER(H.postal_code) = LOWER(AH.zipcode)
	AND LOWER(H.Name) = LOWER(AH.Hotel_Name);

-- -- PHASE 2 -  MATCH EXACT WITH SAME NAME AND WITHIN 100m
-- 7693
UPDATE Public.Hotels AS H
SET Agoda_Hotel_Id = AH.Id
FROM
	Public.Agoda_Hotels AS AH
WHERE
	LOWER(H.Name) = LOWER(AH.Hotel_Name)
	AND ST_DWithin(AH.geog, H.Geog, 100)
	AND H.Agoda_Hotel_Id IS NULL	;

 -- PHASE 3 - MATCH FUZZY NAME ((0.9 correlation) AND WITHIN 500m
-- 5906
UPDATE hotels SET agoda_hotel_id =  matched_hotel.agoda_hotel_id
FROM ( 
	SELECT DISTINCT e.id AS agoda_hotel_id, h.id AS hotel_id 
	FROM agoda_hotels e 
	JOIN hotels h ON ST_DWithin(e.geog, h.geog, 500) 
		WHERE h.agoda_hotel_id IS NULL 
		AND similarity(lower(h.name), lower(e.hotel_name)) >0.9 ) AS matched_hotel
WHERE matched_hotel.hotel_id = hotels.id and hotels.agoda_hotel_id IS NULL;

 -- PHASE 4 - MATCH FUZZY NAME ((0.9 correlation) AND WITHIN 1km
 UPDATE Public.Hotels AS H
SET Agoda_Hotel_Id = AH.Id
FROM
	Public.Agoda_Hotels AS AH
WHERE
	H.agoda_hotel_id IS NULL
	AND ST_DWithin(AH.geog, H.geog, 1000) 
	AND SIMILARITY(H.name, AH.hotel_name) >0.9;
	
	
 -- PHASE 5 - MATCH FUZZY NAME ((0.8 correlation) AND WITHIN 500
 -- 872 131415 ms
UPDATE Public.Hotels AS H
SET Agoda_Hotel_Id = AH.Id
FROM
	Public.Agoda_Hotels AS AH
WHERE
	H.agoda_hotel_id IS NULL
	AND ST_DWithin(AH.geog, H.geog, 500) 
	AND SIMILARITY(H.name, AH.hotel_name) >0.8;
	

 -- PHASE 6 - MATCH FUZZY NAME ((0.85 correlation) AND WITHIN 1000
 -- 149
UPDATE Public.Hotels AS H
SET Agoda_Hotel_Id = AH.Id
FROM
	Public.Agoda_Hotels AS AH
WHERE
	H.agoda_hotel_id IS NULL
	AND ST_DWithin(AH.geog, H.geog, 1000) 
	AND SIMILARITY(H.name, AH.hotel_name) >0.85;
	
-- PHASE 7 - MATCH FUZZY NAME ((0.75 correlation) AND WITHIN 2000
UPDATE Public.Hotels AS H
SET Agoda_Hotel_Id = AH.Id
FROM
	Public.Agoda_Hotels AS AH
WHERE
	H.agoda_hotel_id IS NULL
	AND ST_DWithin(AH.geog, H.geog, 2000) 
	AND SIMILARITY(H.name, AH.hotel_name) >0.75;

-- PHASE 8 - MATCH FUZZY NAME ((0.75 correlation) AND WITHIN 10000
-- 2048
UPDATE Public.Hotels AS H
SET Agoda_Hotel_Id = AH.Id
FROM
	Public.Agoda_Hotels AS AH
WHERE
	H.agoda_hotel_id IS NULL
	AND ST_DWithin(AH.geog, H.geog, 10000) 
	AND SIMILARITY(H.name, AH.hotel_name) >0.8;
	
DELETE FROM  hotels WHERE hotel_provider = 'agoda';
-- PHASE 8 - INSERT all non-matched EAN hotels
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
agoda_hotel_id, 
agoda_user_rating, 
hotel_provider)
SELECT 
	hotel_name as name, 
	addressline1 || coalesce(', ' || addressline2, '')  as address, 
	ah.city as city, 
	state as state_province, 
	zipcode as postal_code, 
	lower(countryisocode) as country_code, 
	ah.longitude, 
	ah.latitude, 
	CAST(ah.star_rating as double precision),
	checkin as check_in_time, 
	checkout as check_out_time, 
	CAST(rates_from as double precision) as low_rate, 
	rates_currency as property_currency, 
	ah.geog, 
	overview as description, 
	ah.id as agoda_hotel_id,
	rating_average as agoda_user_rating,
	'agoda'
FROM agoda_hotels ah
LEFT JOIN hotels h1 ON h1.agoda_hotel_id = ah.id
WHERE h1.id IS NULL

-- DROP TABLE agoda_hotel_images;

CREATE TABLE agoda_hotel_images
(
  id serial NOT NULL,
  agoda_hotel_id integer,
  image_url character varying(255),
  CONSTRAINT agoda_hotel_images_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

CREATE INDEX agoda_hotel_id_idx
  ON hotels
  USING btree
  (agoda_hotel_id);
  
DELETE FROM agoda_hotel_images

INSERT INTO providers.agoda_hotel_images (agoda_hotel_id, image_url)
SELECT
   unnest(array[id]) as agoda_hotel_id,
   unnest(array[photo1, photo2, photo3, photo4, photo5]) AS "image_url"
FROM providers.agoda_hotels

DELETE FROM providers.hotel_images WHERE caption = 'AgodaHotel'

INSERT INTO providers.hotel_images (hotel_id, caption, url, thumbnail_url)
SELECT t1.id, 'AgodaHotel', hi.image_url ,hi.image_url 
FROM providers.agoda_hotel_images hi
JOIN
(SELECT h.id, agoda_hotel_id FROM hotels h 
LEFT JOIN providers.hotel_images i ON h.id = i.hotel_id
WHERE  i.id IS NULL AND  h.agoda_hotel_id IS NOT NULL) as t1
ON t1.agoda_hotel_id = hi.agoda_hotel_id 


CREATE TABLE agoda_hotel_facilities
(
  id serial NOT NULL,
  agoda_hotel_id integer,
  group_description character varying(255),
  property_id integer,
  name character varying(255),
  translated_name character varying(255),
  CONSTRAINT agoda_hotel_facilities_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

CREATE TABLE agoda_amenities
(
  id integer NOT NULL ,
  description text,
  flag integer,
  CONSTRAINT agoda_amenities_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

INSERT INTO agoda_amenities (id, description) 
SELECT DISTINCT property_id, name 
FROM agoda_hotel_amenities
ORDER BY 1 ASC

UPDATE agoda_amenities SET flag = 1 WHERE lower(description) like '%wireless%';
UPDATE agoda_amenities SET flag = 4 WHERE description = 'babysitting' OR description = 'pool (kids)' OR description = 'kids club'  OR description = 'family room' OR description = 'children''s playground';
UPDATE agoda_amenities SET flag = 8 WHERE lower(description) like '%parking%' OR description = 'car park';
UPDATE agoda_amenities SET flag = 16 WHERE description = 'fitness center';
UPDATE agoda_amenities SET flag = 64 WHERE description ='non smoking rooms' OR description = 'smoking area';
UPDATE agoda_amenities SET flag =128 WHERE description = 'pets allowed';
UPDATE agoda_amenities SET flag = 256 WHERE lower(description) like '%pool%' ;
UPDATE agoda_amenities SET flag = 512 WHERE lower(description) like '%restaurant%';
UPDATE agoda_amenities SET flag = 1024 WHERE description = 'spa';


UPDATE hotels
SET amenities = T2.bitmask
FROM (
	SELECT T1.agoda_hotel_id, SUM(T1.flag) AS bitmask
	FROM
	(
		SELECT DISTINCT 
			agoda_hotel_id AS agoda_hotel_id, 
			flag  AS flag
		FROM agoda_hotel_facilities spa
		JOIN agoda_amenities sa on sa.description = spa.name
		WHERE sa.flag IS NOT NULL
		GROUP BY agoda_hotel_id, flag
		ORDER BY 1
	) AS T1
	GROUP BY T1.agoda_hotel_id
) AS T2
WHERE hotels.agoda_hotel_id = T2.agoda_hotel_id AND hotels.amenities IS NULL

