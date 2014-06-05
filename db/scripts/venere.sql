select * from venere_hotels limit 10

DROP INDEX index_hotels_on_venere_hotel_id;
UPDATE hotels SET venere_hotel_id = NULL WHERE venere_hotel_id IS NOT NULL;

--Add Geography
ALTER TABLE venere_hotels ADD COLUMN geog geography(Point,4326);

--Update Geography
UPDATE venere_hotels SET geog = CAST(ST_SetSRID(ST_Point(longitude, latitude),4326) As geography) WHERE geog is NULL;

--Index Geography
CREATE INDEX venere_hotels_geog_idx
  ON venere_hotels
  USING gist(geog);


-- PHASE 1 - MATCH ON NAME / CITY / POSTAL CODE
-- Updated 15882
--select * from venere_hotels limit 100
UPDATE Public.Hotels AS H
SET 
  venere_hotel_id = HP.Id, 
  venere_user_rating = CAST(HP.user_rating AS DOUBLE PRECISION)
FROM
	Public.venere_hotels AS HP
WHERE
	LOWER(H.postal_code) = LOWER(HP.zip)
	AND COALESCE(H.postal_code,'') != ''
	AND LOWER(H.Name) = LOWER(HP.name);

--select * from hotels where lower(name) = 'accommodation delia'

-- -- PHASE 2 -  MATCH EXACT WITH SAME NAME AND WITHIN 100m
-- 3152
UPDATE Public.Hotels AS H
SET 
  venere_hotel_id = HP.Id, 
  venere_user_rating = CAST(HP.user_rating AS DOUBLE PRECISION)
FROM
	Public.venere_hotels AS HP
WHERE
	LOWER(H.Name) = LOWER(HP.name)
	AND ST_DWithin(HP.geog, H.Geog, 100)
	AND H.venere_hotel_id IS NULL;	

 -- PHASE 3 - MATCH FUZZY NAME ((0.9 correlation) AND WITHIN 500m
-- 4628
UPDATE Public.Hotels AS H
SET 
  venere_hotel_id = HP.Id, 
  venere_user_rating = CAST(HP.user_rating AS DOUBLE PRECISION)
FROM
	Public.venere_hotels AS HP
WHERE
	H.venere_hotel_id IS NULL
	AND ST_DWithin(HP.geog, H.geog, 500) 
	AND SIMILARITY(H.name, HP.name) >0.9;
	
 -- PHASE 4 - MATCH FUZZY NAME ((0.9 correlation) AND WITHIN 1km
 -- 442
UPDATE Public.Hotels AS H
SET 
  venere_hotel_id = HP.Id, 
  venere_user_rating = CAST(HP.user_rating AS DOUBLE PRECISION)
FROM
	Public.venere_hotels AS HP
WHERE
	H.venere_hotel_id IS NULL
	AND ST_DWithin(HP.geog, H.geog, 1000) 
	AND SIMILARITY(H.name, HP.name) >0.9;
	
	
 -- PHASE 5 - MATCH FUZZY NAME ((0.8 correlation) AND WITHIN 500
 -- 2295
UPDATE Public.Hotels AS H
SET 
  venere_hotel_id = HP.Id, 
  venere_user_rating = CAST(HP.user_rating AS DOUBLE PRECISION)
FROM
	Public.venere_hotels AS HP
WHERE
	H.venere_hotel_id IS NULL
	AND ST_DWithin(HP.geog, H.geog, 500) 
	AND SIMILARITY(H.name, HP.name) >0.8;
	

 -- PHASE 6 - MATCH FUZZY NAME ((0.85 correlation) AND WITHIN 1000
 --  70
UPDATE Public.Hotels AS H
SET 
  venere_hotel_id = HP.Id,
   venere_user_rating = CAST(HP.user_rating AS DOUBLE PRECISION)
FROM
	Public.venere_hotels AS HP
WHERE
	H.venere_hotel_id IS NULL
	AND ST_DWithin(HP.geog, H.geog, 1000) 
	AND SIMILARITY(H.name, HP.name) >0.85;
	
-- PHASE 7 - MATCH FUZZY NAME ((0.75 correlation) AND WITHIN 2000
--2694
UPDATE Public.Hotels AS H
SET 
  venere_hotel_id = HP.Id, 
  venere_user_rating = CAST(HP.user_rating AS DOUBLE PRECISION)
FROM
	Public.venere_hotels AS HP
WHERE
	H.venere_hotel_id IS NULL
	AND ST_DWithin(HP.geog, H.geog, 2000) 
	AND SIMILARITY(H.name, HP.name) >0.75;

-- PHASE 8 - MATCH FUZZY NAME ((0.75 correlation) AND WITHIN 10000
--  693
UPDATE Public.Hotels AS H
SET 
  venere_hotel_id = HP.Id, 
  venere_user_rating = CAST(HP.user_rating AS DOUBLE PRECISION)
FROM
	Public.venere_hotels AS HP
WHERE
	H.venere_hotel_id IS NULL
	AND ST_DWithin(HP.geog, H.geog, 10000) 
	AND SIMILARITY(H.name, HP.name) >0.8;

select count(*) from hotels WHERE hotel_provider =  'venere';
DELETE FROM  hotels WHERE hotel_provider =  'venere';
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
venere_hotel_id, 
venere_user_rating, 
hotel_provider)
SELECT 
  vh.name as name, 
	vh.address  as address, 
	vh.city as city, 
	vh.state as state_province, 
	vh.zip as postal_code, 
	vh.country_iso_code as country_code,
	--lower(countryisocode) as country_code, 
	vh.longitude, 
	vh.latitude, 
  COALESCE(vh.rating,0) AS star_rating,
	null, 
	null, 
	CAST(vh.price as double precision) as low_rate, 
	vh.currency_code as property_currency, 
	vh.geog, 
	vh.hotel_overview as description, 
  vh.id as venere_hotel_id,
	CAST(vh.user_rating AS DOUBLE PRECISION) as venere_user_rating,
	'venere' AS hotel_provider
FROM venere_hotels vh
LEFT JOIN hotels h1 ON h1.venere_hotel_id = vh.id
WHERE h1.id IS NULL;


CREATE TABLE venere_hotel_images
(
  id serial NOT NULL,
  venere_hotel_id integer,
  image_url character varying(255),
  default_image boolean,
  CONSTRAINT venere_hotel_images_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);


TRUNCATE TABLE venere_hotel_images
INSERT INTO venere_hotel_images (venere_hotel_id, image_url, default_image)
 SELECT id, regexp_split_to_table(image_url, E';'), false 
 FROM venere_hotels; 

update venere_hotel_images vhi
set default_image = true
from (select id, image_url from venere_hotels) as t1
where vhi.venere_hotel_id = t1.id and vhi.image_url = t1.image_url


DELETE FROM hotel_images WHERE caption = 'venere';

INSERT INTO hotel_images (hotel_id, caption, url, thumbnail_url,default_image)
SELECT t1.id, 'venere', hi.image_url, replace(hi.image_url, '_b.', '_t.'), default_image
FROM venere_hotel_images hi
JOIN
(SELECT h.id, venere_hotel_id FROM hotels h 
LEFT JOIN hotel_images i ON h.id = i.hotel_id
WHERE  i.id IS NULL AND  h.venere_hotel_id IS NOT NULL) as t1
ON t1.venere_hotel_id = hi.venere_hotel_id ;


UPDATE hotels
SET venere_url = t1.url
FROM (SELECT id, url FROM venere_hotels lr) as t1
WHERE hotels.venere_hotel_id = t1.id

-- AMENITIES

DROP TABLE venere_hotel_amenities;
CREATE TABLE venere_hotel_amenities
(
  id serial NOT NULL,
  venere_hotel_id integer,
  venere_amenity_id integer,
  CONSTRAINT venere_hotel_amenities_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

TRUNCATE TABLE venere_hotel_amenities;
INSERT INTO venere_hotel_amenities (venere_hotel_id,venere_amenity_id)
select id, CAST(regexp_split_to_table(replace(regexp_replace(concat_ws(';',hotel_amenities, room_amenities), '(\d*-)', '','ig'),';',','), E',') AS INTEGER) from venere_hotels 

DROP TABLE venere_amenities;
 CREATE TABLE venere_amenities
(
  id INTEGER NOT NULL,
  description text,
  flag integer,
  CONSTRAINT venere_amenities_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

-- 1 1|'Wifi'
-- 2 2|'Central Location'
-- 4 3|'Family Friendly'
-- 8 4|'Parking'
-- 16 5|'Gym'
-- 32 6|'Boutique'
-- 64 7|'Non-smoking rooms'
-- 128 8|'Pet Friendly'
-- 256 9|'Pool'
-- 512 10|'Restaurant'
-- 1024 11|'Spa'
select * from venere_amenities
UPDATE venere_amenities SET flag = 1     WHERE id in (205,208);
UPDATE venere_amenities SET flag = 4     WHERE id in (32,33,34,35,46);
UPDATE venere_amenities SET flag = 8     WHERE id in (14, 16, 17, 19, 20, 21);
UPDATE venere_amenities SET flag = 16    WHERE id IN (122, 123, 124, 125, 126);
UPDATE venere_amenities SET flag = 64    WHERE id in (169, 170);
UPDATE venere_amenities SET flag =128    WHERE id in (9, 10);
UPDATE venere_amenities SET flag = 256   WHERE id in (102, 103, 104, 105, 106);
UPDATE venere_amenities SET flag = 512   WHERE id in (58, 59, 60);
UPDATE venere_amenities SET flag = 1024 WHERE id in (134, 141, 146);

UPDATE provider_hotels
SET amenities = T2.bitmask
FROM (
	SELECT T1.provider_id, SUM(T1.flag) AS bitmask
	FROM
	(
		SELECT DISTINCT 
			venere_hotel_id AS provider_id, 
			flag  AS flag
		FROM venere_amenities a
		JOIN venere_hotel_amenities ha on ha.venere_amenity_id = a.id
		WHERE a.flag IS NOT NULL
		GROUP BY venere_hotel_id, flag
		ORDER BY 1
	) AS T1
	GROUP BY T1.provider_id
) AS T2
WHERE provider_hotels.provider_id = T2.provider_id AND provider_hotels.amenities IS NULL AND provider_hotels.provider = 'venere'

UPDATE hotels h
SET star_rating = CASE WHEN COALESCE(h.star_rating, 0) = 0                                
                               then  t1.star_rating 
                               else h.star_rating
                               END,
       venere_user_rating = t1.user_rating_normal, 
       amenities = (COALESCE(h.amenities,0) | t1.amenities)
FROM
 (SELECT * FROM provider_hotels where provider = 'venere' ) AS t1
 WHERE h.venere_hotel_id = T1.provider_id

