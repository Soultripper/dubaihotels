-- Index: hotels_splendia_hotel_id_idx
-- DROP INDEX hotels_splendia_hotel_id_idx;
UPDATE hotels SET  splendia_hotel_id = NULL
select * from ean_countries
-- select count(*) from splendia_hotels
select * from splendia_hotels limit 100
--select * from splendia_hotels where id =97760
--Add Geography
ALTER TABLE splendia_hotels ADD COLUMN geog geography(Point,4326);

--Update Geography
UPDATE splendia_hotels SET geog = CAST(ST_SetSRID(ST_Point(longitude, latitude),4326) As geography)

--Index Geography
CREATE INDEX splendia_hotels_geog_idx
  ON splendia_hotels
  USING gist(geog);
  
UPDATE hotels SET splendia_hotel_id = NULL

-- PHASE 1 - MATCH ON NAME / CITY / POSTAL CODE
-- Updated 961
select * from hotels limit 100
UPDATE Public.Hotels AS H
SET splendia_hotel_id = SPL.Id
FROM
	Public.splendia_hotels AS SPL
WHERE
	LOWER(H.city) = LOWER(SPL.city)
	AND LOWER(H.postal_code) = LOWER(SPL.postal_code)
	AND COALESCE(H.postal_code,'') != ''
	AND LOWER(H.Name) = LOWER(SPL.name);

-- -- PHASE 2 -  MATCH EXACT WITH SAME NAME AND WITHIN 100m
-- 437
UPDATE Public.Hotels AS H
SET splendia_hotel_id = SPL.Id
FROM
	Public.splendia_hotels AS SPL
WHERE
	LOWER(H.Name) = LOWER(SPL.name)
	AND ST_DWithin(SPL.geog, H.Geog, 100)
	AND H.splendia_hotel_id IS NULL;	

 -- PHASE 3 - MATCH FUZZY NAME ((0.9 correlation) AND WITHIN 500m
-- 374
UPDATE hotels SET splendia_hotel_id =  matched_hotel.splendia_hotel_id
FROM ( 
	SELECT DISTINCT e.id AS splendia_hotel_id, h.id AS hotel_id 
	FROM splendia_hotels e 
	JOIN hotels h ON ST_DWithin(e.geog, h.geog, 500) 
		WHERE h.splendia_hotel_id IS NULL 
		AND similarity(lower(h.name), lower(e.name)) >0.9 ) AS matched_hotel
WHERE matched_hotel.hotel_id = hotels.id and hotels.splendia_hotel_id IS NULL;

 -- PHASE 4 - MATCH FUZZY NAME ((0.9 correlation) AND WITHIN 1km
 -- 58
 UPDATE Public.Hotels AS H
SET splendia_hotel_id = SPL.Id
FROM
	Public.splendia_hotels AS SPL
WHERE
	H.splendia_hotel_id IS NULL
	AND ST_DWithin(SPL.geog, H.geog, 1000) 
	AND SIMILARITY(H.name, SPL.name) >0.9;
	
	
 -- PHASE 5 - MATCH FUZZY NAME ((0.8 correlation) AND WITHIN 500
 -- 222
UPDATE Public.Hotels AS H
SET splendia_hotel_id = SPL.Id
FROM
	Public.splendia_hotels AS SPL
WHERE
	H.splendia_hotel_id IS NULL
	AND ST_DWithin(SPL.geog, H.geog, 500) 
	AND SIMILARITY(H.name, SPL.name) >0.8;
	

 -- PHASE 6 - MATCH FUZZY NAME ((0.85 correlation) AND WITHIN 1000
 --  5
UPDATE Public.Hotels AS H
SET splendia_hotel_id = SPL.Id
FROM
	Public.splendia_hotels AS SPL
WHERE
	H.splendia_hotel_id IS NULL
	AND ST_DWithin(SPL.geog, H.geog, 1000) 
	AND SIMILARITY(H.name, SPL.name) >0.85;
	
-- PHASE 7 - MATCH FUZZY NAME ((0.75 correlation) AND WITHIN 2000
-- 280
UPDATE Public.Hotels AS H
SET splendia_hotel_id = SPL.Id
FROM
	Public.splendia_hotels AS SPL
WHERE
	H.splendia_hotel_id IS NULL
	AND ST_DWithin(SPL.geog, H.geog, 2000) 
	AND SIMILARITY(H.name, SPL.name) >0.75;

-- PHASE 8 - MATCH FUZZY NAME ((0.75 correlation) AND WITHIN 10000
--  92
UPDATE Public.Hotels AS H
SET splendia_hotel_id = SPL.Id
FROM
	Public.splendia_hotels AS SPL
WHERE
	H.splendia_hotel_id IS NULL
	AND ST_DWithin(SPL.geog, H.geog, 10000) 
	AND SIMILARITY(H.name, SPL.name) >0.8;

select * from splendia_hotels
--delete from hotels where hotel_provider = 'agoda'
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
splendia_hotel_id, 
user_rating, 
hotel_provider)
SELECT 
	SPL.name as name, 
	SPL.street  as address, 
	SPL.city as city, 
	SPL.state_province_name as state_province, 
	SPL.postal_code as postal_code, 
	countries.country_code as country_code,
	--lower(countryisocode) as country_code, 
	SPL.longitude, 
	SPL.latitude, 
	CASE substr(stars,2,1) WHEN '' THEN NULL ELSE CAST(substr(stars,2,1) AS DOUBLE PRECISION) END AS star_rating,
	NULL AS check_in,
	NULL AS check_out, 
	CAST(price as double precision) as low_rate, 
	SPL.currency as property_currency, 
	SPL.geog, 
	SPL.description as description, 
	SPL.id as splendia_hotel_id,
	CAST(replace(rating,'%','') AS DOUBLE PRECISION) as user_rating,
	'splendia' AS hotel_provider
FROM splendia_hotels SPL
JOIN ean_countries countries on countries.country_name = SPL.country
LEFT JOIN hotels h1 ON h1.splendia_hotel_id = SPL.id
WHERE h1.id IS NULL


CREATE INDEX hotels_splendia_hotel_id_idx
  ON hotels
  USING btree
  (splendia_hotel_id);
  

select * from SPL_hotel_images limit 100

-- 
INSERT INTO hotel_images (hotel_id, caption, url, thumbnail_url,default_image)
SELECT t1.id, 'Splendia', hi.big_image,hi.small_image, false
FROM splendia_hotels hi
JOIN
(SELECT h.id, splendia_hotel_id FROM hotels h 
LEFT JOIN hotel_images i ON h.id = i.hotel_id
WHERE  i.id IS NULL AND  h.splendia_hotel_id IS NOT NULL) as t1
ON t1.splendia_hotel_id = hi.id 

-- CREATE TABLE late_rooms_amenities
-- (
--   id serial NOT NULL,
--   splendia_hotel_id integer,
--   amenity character varying(255),
--   CONSTRAINT late_rooms_amenities_pkey PRIMARY KEY (id)
-- )
-- WITH (
--   OIDS=FALSE
-- );
-- ALTER TABLE late_rooms_amenities
--   OWNER TO "Sky";

INSERT INTO late_rooms_amenities (splendia_hotel_id, amenity)
 SELECT id, regexp_split_to_table(facilities, E';') 
 FROM splendia_hotels 


select * from late_rooms_amenities limit 1000

CREATE  INDEX index_splendia_hotel_id_on_late_rooms_amenities
  ON late_rooms_amenities
  USING btree
  (splendia_hotel_id);