-- Index: hotels_etb_hotel_id_idx
select * from etb_hotel_descriptions
-- DROP INDEX hotels_etb_hotel_id_idx;
UPDATE hotels SET  etb_hotel_id = NULL

-- select count(*) from etb_hotels
select * from etb_hotels limit 100
--select * from etb_hotels where id =97760
--Add Geography
ALTER TABLE etb_hotels ADD COLUMN geog geography(Point,4326);

--Update Geography
UPDATE etb_hotels SET geog = CAST(ST_SetSRID(ST_Point(longitude, latitude),4326) As geography)

--Index Geography
CREATE INDEX etb_hotels_geog_idx
  ON etb_hotels
  USING gist(geog);
  
UPDATE hotels SET etb_hotel_id = NULL

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

select * from etb_hotels
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
etb_hotel_id, 
user_rating, 
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
	CAST(hotel_review_score AS DOUBLE PRECISION) as user_rating,
	'easytobook' AS hotel_provider
FROM etb_hotels ETB
JOIN etb_cities cities on cities.id = ETB.city_id
JOIN etb_countries countries on countries.id = cities.country_id
JOIN etb_hotel_descriptions descs on descs.etb_hotel_id = ETB.id
LEFT JOIN hotels h1 ON h1.etb_hotel_id = ETB.id
WHERE h1.id IS NULL


CREATE INDEX hotels_etb_hotel_id_idx
  ON hotels
  USING btree
  (etb_hotel_id);
  

select * from etb_hotel_images limit 100

-- 
-- INSERT INTO hotel_images (hotel_id, caption, url, thumbnail_url,default_image)
-- SELECT t1.id, 'EasyToBookHotel', hi.image,hi.image, false
-- FROM etb_hotel_images hi
-- JOIN
-- (SELECT h.id, etb_hotel_id FROM hotels h 
-- LEFT JOIN hotel_images i ON h.id = i.hotel_id
-- WHERE  i.id IS NULL AND  h.etb_hotel_id IS NOT NULL) as t1
-- ON t1.etb_hotel_id = hi.etb_hotel_id 

-- CREATE TABLE late_rooms_amenities
-- (
--   id serial NOT NULL,
--   etb_hotel_id integer,
--   amenity character varying(255),
--   CONSTRAINT late_rooms_amenities_pkey PRIMARY KEY (id)
-- )
-- WITH (
--   OIDS=FALSE
-- );
-- ALTER TABLE late_rooms_amenities
--   OWNER TO "Sky";

INSERT INTO late_rooms_amenities (etb_hotel_id, amenity)
 SELECT id, regexp_split_to_table(facilities, E';') 
 FROM etb_hotels 


select * from late_rooms_amenities limit 1000

CREATE  INDEX index_etb_hotel_id_on_late_rooms_amenities
  ON late_rooms_amenities
  USING btree
  (etb_hotel_id);