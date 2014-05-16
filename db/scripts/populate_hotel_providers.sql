-- Table: provider_hotels
-- select * from agoda_hotels limit 100 -- Agoda is out of 10
-- select * from booking_hotels limit 100 -- Booking is out of 10
-- select * from late_rooms_hotels limit 100  -- laterooms is out of 6
-- select * from etb_hotels limit 100  -- EasyToBook is out of 5
-- select * from splendia_hotels limit 100 -- Splendia is out of 100%
-- select * from ean_hotels limit 100 -- EAN hotels have no user score
-- select * from hotels limit 100

-- DROP TABLE provider_hotels;
-- 
-- 
CREATE TABLE provider_hotels
(
  id serial NOT NULL,
  hotel_id integer,
  provider_id character varying(255),
  provider_hotel_id integer,
  name character varying(255),
  address text,
  city character varying(255),
  state_province character varying(255),
  postal_code character varying(255),
  country_code character varying(255),
  latitude double precision,
  longitude double precision,
  description text,
  amenities integer,
  star_rating double precision,
  user_rating double precision,
  hotel_link character varying(512),
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  user_rating_normal double precision,
  star_rating_normal double precision,
  ranking double precision,
  name_normal character varying(255),
  geog geography(Point,4326),
  image_url character varying(255),
  thumbnail_url character varying(255),
  CONSTRAINT provider_hotels_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);



 
-- EAN
--SELECT * FROM ean_hotels LIMIT 1
 -- EAN hotels have no user score
INSERT INTO provider_hotels (hotel_id, provider_id, provider_hotel_id, name, address, city, state_province, postal_code, country_code, latitude, longitude, description, star_rating, user_rating, hotel_link, created_at, updated_at, user_rating_normal, ranking)
SELECT 
	null AS hotel_id,
	'expedia' AS provider_id,
	h.id,
	h.name, 
	COALESCE(h.address1,'') || COALESCE(COALESCE(', ' || h.address2, '') || COALESCE(', ' || h.state_province),'') AS address, 
	h.city, 
	h.state_province,
	h.postal_code, 
	LOWER(h.country) AS country_code,
	h.latitude, 
	h.longitude,  
	d.description, 
	h.star_rating, 
	null AS user_rating,
	null	AS hotel_link,
	now() AS created_at,
	now() AS updated_at,
	0, 
	sequence_number
FROM ean_hotels h
LEFT JOIN ean_hotel_descriptions d ON d.ean_hotel_id = h.id;

-- BOOKING
--SELECT * FROM booking_hotels LIMIT 1
-- Booking is out of 10
INSERT INTO provider_hotels (hotel_id, provider_id, provider_hotel_id, name, address, city, state_province, postal_code, country_code, latitude, longitude, description, star_rating, user_rating, hotel_link, created_at, updated_at, user_rating_normal, ranking)
SELECT 
	null AS hotel_id,
	'booking' AS provider_id,
	h.id,
	h.name, 
	h.address, 
	h.city, 
	h.district,
	h.zip AS postal_code, 
	h.country_code,
	h.latitude, 
	h.longitude,  
	d.description, 
	COALESCE(h.classification,0) AS star_rating, 
	CAST(h.review_score AS DOUBLE PRECISION) AS user_rating,
	h.url AS hotel_link,
	now() AS created_at,
	now() AS updated_at,
	COALESCE(CAST(h.review_score AS DOUBLE PRECISION) * 10,0) AS user_rating_normal,
	ranking	
FROM booking_hotels h
LEFT JOIN booking_hotel_descriptions d ON d.booking_hotel_id = h.id;

-- AGODA
--SELECT * FROM agoda_hotels LIMIT 1
-- Agoda is out of 10
INSERT INTO provider_hotels (hotel_id, provider_id, provider_hotel_id, name, address, city, state_province, postal_code, country_code, latitude, longitude, description, star_rating, user_rating, hotel_link, created_at, updated_at, user_rating_normal, ranking)
SELECT 
	null AS hotel_id,
	'agoda' AS provider_id,
	h.id,
	h.hotel_name AS name, 
	COALESCE(h.addressline1,'') || COALESCE(COALESCE(', ' || h.addressline2, '')) AS address , 
	h.city, 
	h.state,
	h.zipcode AS postal_code, 
	h.countryisocode,
	h.latitude, 
	h.longitude,  
	h.overview AS description, 
	COALESCE(CAST(h.star_rating AS DOUBLE PRECISION)) AS star_rating, 
	CAST(h.rating_average AS DOUBLE PRECISION) AS user_rating,
	h.url AS hotel_link,
	now() AS created_at,
	now() AS updated_at,
	COALESCE(CAST(h.rating_average AS DOUBLE PRECISION) * 10,0) AS user_rating_normal,
	CAST(h.star_rating AS DOUBLE PRECISION) AS star_rating
FROM agoda_hotels h;

-- Laterooms
--SELECT * FROM late_rooms_hotels LIMIT 1
-- laterooms is out of 6
INSERT INTO provider_hotels (hotel_id, provider_id, provider_hotel_id, name, address, city, state_province, postal_code, country_code, latitude, longitude, description, star_rating, user_rating, hotel_link, created_at, updated_at, user_rating_normal, ranking)
SELECT 
	null AS hotel_id,
	'laterooms' AS provider_id,
	h.id,
	h.name AS name, 
	h.address1 AS address, 
	h.city, 
	h.county,
	h.postcode AS postal_code, 
	LOWER(h.country_iso) AS country_code,
	h.latitude, 
	h.longitude,  
	h.description AS description, 
	CASE left(h.star_rating, 1) 
		WHEN 'N' THEN null 
		WHEN 'A' THEN null 
		WHEN 'B' THEN null 
		WHEN 'T' THEN null 
		ELSE CAST(left(h.star_rating, 1) AS DOUBLE PRECISION) END AS star_rating,
	CAST(score_out_of_6 AS DOUBLE PRECISION) AS user_rating,
	h.url AS hotel_link,
	now() AS created_at,
	now() AS updated_at,
	COALESCE(CAST(score_out_of_6 AS DOUBLE PRECISION) * 16.666,0) AS user_rating_normal,
	0 AS ranking	
FROM late_rooms_hotels h;

--easy_to_book
--SELECT * FROM etb_hotels LIMIT 1
-- EasyToBook is out of 5
INSERT INTO provider_hotels (hotel_id, provider_id, provider_hotel_id, name, address, city, state_province, postal_code, country_code, latitude, longitude, description, star_rating, user_rating, hotel_link, created_at, updated_at, user_rating_normal, ranking)
SELECT 
	null AS hotel_id,
	'easy_to_book' AS provider_id,
	h.id,
	h.name AS name, 
	h.address AS address , 
	h.address_city AS city, 
	c.province_name AS state_province,
	h.zipcode AS postal_code, 
	LOWER(countries.country_iso) AS country_code,
	h.latitude, 
	h.longitude,  
	d.description AS description, 
	CAST(h.stars AS DOUBLE PRECISION) AS star_rating,
	CAST(h.hotel_review_score AS DOUBLE PRECISION) AS user_rating,
	h.url AS hotel_link,
	now() AS created_at,
	now() AS updated_at,
	COALESCE(CAST(h.hotel_review_score AS DOUBLE PRECISION) * 20,0) AS user_rating_normal,
	0 AS ranking
FROM etb_hotels h
LEFT JOIN etb_cities c ON c.id = h.city_id
LEFT JOIN etb_countries countries on countries.id = c.country_id
LEFT JOIN etb_hotel_descriptions d on d.etb_hotel_id = h.id;

-- SPLENDIA
--SELECT * FROM splendia_hotels LIMIT 100
-- Splendia is out of 100%
INSERT INTO provider_hotels (hotel_id, provider_id, provider_hotel_id, name, address, city, state_province, postal_code, country_code, latitude, longitude, description, star_rating, user_rating, hotel_link, created_at, updated_at, user_rating_normal, ranking)
SELECT 
	null AS hotel_id,
	'splendia' AS provider_id,
	h.id,
	h.name AS name, 
	h.street AS address , 
	h.city AS city, 
	h.state_province_name AS state_province,
	h.postal_code AS postal_code, 
	LOWER(countries.country_code )as country_code,
	h.latitude, 
	h.longitude,  
	h.description AS description, 
	CASE substr(h.stars,2,1) WHEN '' THEN NULL ELSE CAST(substr(h.stars,2,1) AS DOUBLE PRECISION) END AS star_rating,
	CAST(replace(h.rating,'%','') AS DOUBLE PRECISION) as user_rating,
	h.product_url AS hotel_link,
	now() AS created_at,
	now() AS updated_at,
	COALESCE(CAST(replace(h.rating,'%','') AS DOUBLE PRECISION),0) as user_rating,
	0 AS ranking
FROM splendia_hotels h
LEFT JOIN ean_countries countries on countries.country_name = h.country;

-- VENERE
--SELECT * FROM venere_hotels LIMIT 100
-- user_rating out of 10
INSERT INTO provider_hotels (hotel_id, provider_id, provider_hotel_id, name, address, city, state_province, postal_code, country_code, latitude, longitude, description, star_rating, user_rating, hotel_link, created_at, updated_at, user_rating_normal, ranking)
SELECT 
	null AS hotel_id,
	'venere' AS provider_id,
	h.id,
	h.name AS name, 
	h.address AS address, 
	h.city AS city, 
	h.province AS state_province,
	h.zip AS postal_code, 
	LOWER(h.country_iso_code )as country_code,
	h.latitude, 
	h.longitude,  
	h.hotel_overview AS description, 
	CAST(h.rating AS DOUBLE PRECISION) AS star_rating,
	CAST(h.user_rating AS DOUBLE PRECISION) AS user_rating,
	h.property_url AS hotel_link,
	now() AS created_at,
	now() AS updated_at,
	COALESCE(CAST(h.user_rating AS DOUBLE PRECISION) * 10, 0) AS user_rating_normal,
	0 AS ranking
FROM venere_hotels h;

--SELECT COUNT(*) FROM provider_hotels
 UPDATE provider_hotels SET geog = ST_MakePoint(longitude, latitude);


