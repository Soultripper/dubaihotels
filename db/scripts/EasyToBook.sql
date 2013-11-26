--Add Geography
ALTER TABLE etb_hotels ADD COLUMN geog geography(Point,4326);

--Update Geography
UPDATE etb_hotels SET geog = CAST(ST_SetSRID(ST_Point(longitude, latitude),4326) As geography)
WHERE (longitude BETWEEN -180 AND 180)
AND (Latitude BETWEEN -90 AND 90);
--Except for hotel 445969 which has an invalid latitude :s

--Index Geography
CREATE INDEX etb_hotels_geog_idx
  ON etb_hotels
  USING gist(geog);

--86,090 to match

--Initial update of 67631
UPDATE Public.Hotels AS H
SET etb_hotel_Id = AH.Id
FROM
	Public.etb_hotels AS AH
JOIN etb_cities city on city.id = AH.city_id
JOIN etb_countries c on c.id = city.country_id
WHERE
	LOWER(H.country_code) = LOWER(c.country_iso)
	AND LOWER(H.postal_code) = LOWER(AH.zipcode)
	AND LOWER(H.Name) = LOWER(AH.name)

--Second pass of 25,090
UPDATE Public.Hotels AS H
SET etb_hotel_Id = AH.Id
FROM
	Public.etb_hotels AS AH
JOIN etb_cities city on city.id = AH.city_id
JOIN etb_countries c on c.id = city.country_id
WHERE
	LOWER(H.country_code) = LOWER(c.country_iso)
	AND LOWER(H.Name) = LOWER(AH.name)
	AND ST_DWithin(AH.geog, H.Geog, 500)
	AND H.etb_Hotel_Id IS NULL	

--Third pass of 737
UPDATE Public.Hotels AS H
SET etb_hotel_Id = AH.Id
FROM
	Public.etb_hotels AS AH
JOIN etb_cities city on city.id = AH.city_id
JOIN etb_countries c on c.id = city.country_id
WHERE
	LOWER(H.country_code) = LOWER(c.country_iso)
	AND LOWER(H.Name) = LOWER(AH.name)
	AND ST_DWithin(AH.geog, H.Geog, 1000)
	AND H.etb_Hotel_Id IS NULL

--Fourth pass of 985
UPDATE Public.Hotels AS H
SET etb_hotel_Id = AH.Id
FROM
	Public.etb_hotels AS AH
JOIN etb_cities city on city.id = AH.city_id
JOIN etb_countries c on c.id = city.country_id
WHERE
	LOWER(H.country_code) = LOWER(c.country_iso)
	AND LOWER(H.Name) = LOWER(AH.name)
	AND ST_DWithin(AH.geog, H.Geog, 10000)
	AND H.etb_Hotel_Id IS NULL	


-- PHASE 4 - MATCH FUZZY NAME ((0.9 correlation) AND WITHIN 500m (8440)
UPDATE hotels SET etb_hotel_id =  matched_hotel.etb_hotel_id
FROM ( 
	SELECT DISTINCT e.id AS etb_hotel_id, h.id AS hotel_id 
	FROM etb_hotels e
	JOIN hotels h ON ST_DWithin(e.geog, h.geog, 500) 
		WHERE h.etb_hotel_id IS NULL 
		AND similarity(h.name, e.name) >0.9 
		AND h.etb_hotel_id IS NULL) AS matched_hotel
WHERE matched_hotel.hotel_id = hotels.id 

-- PHASE 5 - MATCH FUZZY NAME ((0.9 correlation) AND WITHIN 1km (355)
UPDATE hotels SET etb_hotel_id =  matched_hotel.etb_hotel_id
FROM ( 
	SELECT DISTINCT e.id AS etb_hotel_id, h.id AS hotel_id 
	FROM etb_hotels e
	JOIN hotels h ON ST_DWithin(e.geog, h.geog, 1000) 
		WHERE h.etb_hotel_id IS NULL 
		AND similarity(h.name, e.name) >0.9 
		AND h.etb_hotel_id IS NULL) AS matched_hotel
WHERE matched_hotel.hotel_id = hotels.id 

-- PHASE 6 - MATCH FUZZY NAME ((0.8 correlation) AND WITHIN 500 (8570)
UPDATE hotels SET etb_hotel_id =  matched_hotel.etb_hotel_id
FROM ( 
	SELECT DISTINCT e.id AS etb_hotel_id, h.id AS hotel_id 
	FROM etb_hotels e
	JOIN hotels h ON ST_DWithin(e.geog, h.geog, 500) 
		WHERE h.etb_hotel_id IS NULL 
		AND similarity(h.name, e.name) >0.8
		AND h.etb_hotel_id IS NULL) AS matched_hotel
WHERE matched_hotel.hotel_id = hotels.id 

-- PHASE 7 - MATCH FUZZY NAME ((0.85 correlation) AND WITHIN 1000 (169)
UPDATE hotels SET etb_hotel_id =  matched_hotel.etb_hotel_id
FROM ( 
	SELECT DISTINCT e.id AS etb_hotel_id, h.id AS hotel_id 
	FROM etb_hotels e
	JOIN hotels h ON ST_DWithin(e.geog, h.geog, 1000) 
		WHERE h.etb_hotel_id IS NULL 
		AND similarity(h.name, e.name) >0.85
		AND h.etb_hotel_id IS NULL) AS matched_hotel
WHERE matched_hotel.hotel_id = hotels.id 

-- PHASE 8 - MATCH FUZZY NAME ((0.75 correlation) AND WITHIN 2000 (6894)
UPDATE hotels SET etb_hotel_id =  matched_hotel.etb_hotel_id
FROM ( 
	SELECT DISTINCT e.id AS etb_hotel_id, h.id AS hotel_id 
	FROM etb_hotels e
	JOIN hotels h ON ST_DWithin(e.geog, h.geog, 20000) 
		WHERE h.etb_hotel_id IS NULL 
		AND similarity(h.name, e.name) >0.75
		AND h.etb_hotel_id IS NULL) AS matched_hotel
WHERE matched_hotel.hotel_id = hotels.id 

-- PHASE 9 - INSERT all non-matched EAN hotels (29282)
INSERT INTO hotels (name, address, city, postal_code, country_code, longitude, latitude, star_rating, check_in_time, check_out_time, etb_hotel_id)
select * from (
	SELECT e.name, e.address ||  COALESCE(', ' || city.province_name,''), e.address_city , e.zipcode, c.country_iso, e.longitude, e.latitude, e.stars, e.check_in, e.check_out, e.id
	from etb_hotels e
	JOIN etb_cities city on city.id = e.city_id
	JOIN etb_countries c on c.id = city.country_id
	left join hotels h on h.etb_hotel_id = e.id
	where h.id is null) as main



-- IMAGE INSERTS
-- insert into hotel_images (hotel_id, caption, url, width, height, byte_size, thumbnail_url, default_image)
-- select h.id, i.caption, i.url, i.width, i.height, i.byte_size, i.thumbnail_url, i.default_image from hotels h
-- join etb_hotel_images i on i.ean_hotel_id = h.etb_hotel_id

select * from etb_hotel_images limit 10


