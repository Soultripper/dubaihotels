-- select count(*) from late_rooms_hotels
-- select * from hotels where name = 'Idea Hotel Roma Nomentana' and postal_code = '00050' order by name
-- select postal_code, name from hotels where postal_code is not null group by postal_code, name having count(*) > 1

DROP INDEX index_hotels_on_laterooms_hotel_id;


  

--delete from hotels where id = 417989
--select * from late_rooms_hotels where id =97760

--Add Geography
ALTER TABLE late_rooms_hotels ADD COLUMN geog geography(Point,4326);

--Update Geography
UPDATE late_rooms_hotels SET geog = CAST(ST_SetSRID(ST_Point(longitude, latitude),4326) As geography)

--Index Geography
CREATE INDEX late_rooms_hotels_geog_idx
  ON late_rooms_hotels
  USING gist(geog);

-- PHASE 1 - MATCH ON NAME / CITY / POSTAL CODE
-- Updated 15882
--select * from late_rooms_hotels limit 100
UPDATE Public.Hotels AS H
SET laterooms_hotel_id = LR.Id
FROM
	Public.late_rooms_hotels AS LR
WHERE
	LOWER(H.postal_code) = LOWER(LR.postcode)
	AND COALESCE(H.postal_code,'') != ''
	AND LOWER(H.Name) = LOWER(LR.name)

--select * from hotels where lower(name) = 'accommodation delia'

-- -- PHASE 2 -  MATCH EXACT WITH SAME NAME AND WITHIN 100m
-- 
UPDATE Public.Hotels AS H
SET laterooms_hotel_id = LR.Id
FROM
	Public.late_rooms_hotels AS LR
WHERE
	LOWER(H.Name) = LOWER(LR.name)
	AND ST_DWithin(LR.geog, H.Geog, 100)
	AND H.laterooms_hotel_id IS NULL	

 -- PHASE 3 - MATCH FUZZY NAME ((0.9 correlation) AND WITHIN 500m
-- 
UPDATE hotels SET laterooms_hotel_id =  matched_hotel.laterooms_hotel_id
FROM ( 
	SELECT DISTINCT e.id AS laterooms_hotel_id, h.id AS hotel_id 
	FROM late_rooms_hotels e 
	JOIN hotels h ON ST_DWithin(e.geog, h.geog, 500) 
		WHERE h.laterooms_hotel_id IS NULL 
		AND similarity(lower(h.name), lower(e.name)) >0.9 ) AS matched_hotel
WHERE matched_hotel.hotel_id = hotels.id and hotels.laterooms_hotel_id IS NULL

 -- PHASE 4 - MATCH FUZZY NAME ((0.9 correlation) AND WITHIN 1km
 UPDATE Public.Hotels AS H
SET laterooms_hotel_id = LR.Id
FROM
	Public.late_rooms_hotels AS LR
WHERE
	H.laterooms_hotel_id IS NULL
	AND ST_DWithin(LR.geog, H.geog, 1000) 
	AND SIMILARITY(H.name, LR.name) >0.9
	
	
 -- PHASE 5 - MATCH FUZZY NAME ((0.8 correlation) AND WITHIN 500
 -- 872 131415 ms
UPDATE Public.Hotels AS H
SET laterooms_hotel_id = LR.Id
FROM
	Public.late_rooms_hotels AS LR
WHERE
	H.laterooms_hotel_id IS NULL
	AND ST_DWithin(LR.geog, H.geog, 500) 
	AND SIMILARITY(H.name, LR.name) >0.8
	

 -- PHASE 6 - MATCH FUZZY NAME ((0.85 correlation) AND WITHIN 1000
 -- 149
UPDATE Public.Hotels AS H
SET laterooms_hotel_id = LR.Id
FROM
	Public.late_rooms_hotels AS LR
WHERE
	H.laterooms_hotel_id IS NULL
	AND ST_DWithin(LR.geog, H.geog, 1000) 
	AND SIMILARITY(H.name, LR.name) >0.85
	
-- PHASE 7 - MATCH FUZZY NAME ((0.75 correlation) AND WITHIN 2000
UPDATE Public.Hotels AS H
SET laterooms_hotel_id = LR.Id
FROM
	Public.late_rooms_hotels AS LR
WHERE
	H.laterooms_hotel_id IS NULL
	AND ST_DWithin(LR.geog, H.geog, 2000) 
	AND SIMILARITY(H.name, LR.name) >0.75

-- PHASE 8 - MATCH FUZZY NAME ((0.75 correlation) AND WITHIN 10000
-- 2048
UPDATE Public.Hotels AS H
SET laterooms_hotel_id = LR.Id
FROM
	Public.late_rooms_hotels AS LR
WHERE
	H.laterooms_hotel_id IS NULL
	AND ST_DWithin(LR.geog, H.geog, 10000) 
	AND SIMILARITY(H.name, LR.name) >0.8
	
--delete from hotels where hotel_provider = 'agoda'
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
laterooms_hotel_id, 
user_rating, 
hotel_provider)
SELECT 
	hotel_name as name, 
	addressline1 || coalesce(', ' || addressline2, '')  as address, 
	city as city, 
	state as state_province, 
	postcode as postal_code, 
	lower(countryisocode) as country_code, 
	longitude, 
	latitude, 
	CAST(star_rating as double precision),
	checkin as check_in_time, 
	checkout as check_out_time, 
	CAST(rates_from as double precision) as low_rate, 
	rates_currency as property_currency, 
	geog, 
	overview as description, 
	id as laterooms_hotel_id,
	rating_average as user_rating,
	'agoda'
from late_rooms_hotels

INSERT INTO agoda_hotel_images (laterooms_hotel_id, image_url)
SELECT
   unnest(array[id]) as laterooms_hotel_id,
   unnest(array[photo1, photo2, photo3, photo4, photo5]) AS "image_url"
FROM late_rooms_hotels


INSERT INTO hotel_images (hotel_id, caption, url, thumbnail_url)
SELECT t1.id, 'AgodaHotel', hi.image_url ,hi.image_url 
FROM agoda_hotel_images hi
JOIN
(SELECT h.id, laterooms_hotel_id FROM hotels h 
LEFT JOIN hotel_images i ON h.id = i.hotel_id
WHERE  i.id IS NULL AND  h.laterooms_hotel_id IS NOT NULL) as t1
ON t1.laterooms_hotel_id = hi.laterooms_hotel_id 

CREATE  INDEX index_hotels_on_laterooms_hotel_id
  ON hotels
  USING btree
  (laterooms_hotel_id);
	