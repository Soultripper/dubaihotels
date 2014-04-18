-- Table: provider_hotels

-- DROP TABLE provider_hotels;

-- CREATE TABLE provider_hotels
-- (
--   id serial NOT NULL,
--   hotel_id integer,
--   provider_id character varying(255),
--   provider_hotel_id integer,
--   name character varying(255),
--   address text,
--   city character varying(255),
--   state_province character varying(255),
--   postal_code character varying(255),
--   country_code character varying(255),
--   latitude double precision,
--   longitude double precision,
--   description text,
--   amenities integer,
--   star_rating double precision,
--   user_rating double precision,
--   hotel_link character varying(512),
--   created_at timestamp without time zone NOT NULL,
--   updated_at timestamp without time zone NOT NULL,
--   CONSTRAINT provider_hotels_pkey PRIMARY KEY (id)
-- )
-- WITH (
--   OIDS=FALSE
-- );

 ALTER TABLE provider_hotels  ADD COLUMN geog geography(Point,4326);

-- EAN
--SELECT * FROM ean_hotels LIMIT 1

INSERT INTO provider_hotels (hotel_id, provider_id, provider_hotel_id, name, address, city, state_province, postal_code, country_code, latitude, longitude, description, star_rating, user_rating, hotel_link, created_at, updated_at)
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
	now(),
	now()
FROM ean_hotels h
LEFT JOIN ean_hotel_descriptions d ON d.ean_hotel_id = h.id;

-- BOOKING
--SELECT * FROM booking_hotels LIMIT 1

INSERT INTO provider_hotels (hotel_id, provider_id, provider_hotel_id, name, address, city, state_province, postal_code, country_code, latitude, longitude, description, star_rating, user_rating, hotel_link, created_at, updated_at)
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
	h.classification AS star_rating, 
	CAST(h.review_score AS DOUBLE PRECISION) AS user_rating,
	h.url AS hotel_link,
	now() AS created_at,
	now() AS updated_at
FROM booking_hotels h
LEFT JOIN booking_hotel_descriptions d ON d.booking_hotel_id = h.id;

-- AGODA
--SELECT * FROM agoda_hotels LIMIT 1

INSERT INTO provider_hotels (hotel_id, provider_id, provider_hotel_id, name, address, city, state_province, postal_code, country_code, latitude, longitude, description, star_rating, user_rating, hotel_link, created_at, updated_at)
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
	CAST(h.star_rating AS DOUBLE PRECISION) AS star_rating, 
	CAST(h.rating_average AS DOUBLE PRECISION) AS user_rating,
	h.url AS hotel_link,
	now() AS created_at,
	now() AS updated_at
FROM agoda_hotels h;

-- Laterooms
--SELECT * FROM late_rooms_hotels LIMIT 1

INSERT INTO provider_hotels (hotel_id, provider_id, provider_hotel_id, name, address, city, state_province, postal_code, country_code, latitude, longitude, description, star_rating, user_rating, hotel_link, created_at, updated_at)
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
	now() AS updated_at
FROM late_rooms_hotels h;

--easy_to_book
--SELECT * FROM etb_hotels LIMIT 1

INSERT INTO provider_hotels (hotel_id, provider_id, provider_hotel_id, name, address, city, state_province, postal_code, country_code, latitude, longitude, description, star_rating, user_rating, hotel_link, created_at, updated_at)
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
	now() AS updated_at
FROM etb_hotels h
LEFT JOIN etb_cities c ON c.id = h.city_id
LEFT JOIN etb_countries countries on countries.id = c.country_id
LEFT JOIN etb_hotel_descriptions d on d.etb_hotel_id = h.id;

-- SPLENDIA
--SELECT * FROM splendia_hotels LIMIT 100

INSERT INTO provider_hotels (hotel_id, provider_id, provider_hotel_id, name, address, city, state_province, postal_code, country_code, latitude, longitude, description, star_rating, user_rating, hotel_link, created_at, updated_at)
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
	now() AS updated_at
FROM splendia_hotels h
LEFT JOIN ean_countries countries on countries.country_name = h.country;

-- VENERE
--SELECT * FROM venere_hotels LIMIT 100

INSERT INTO provider_hotels (hotel_id, provider_id, provider_hotel_id, name, address, city, state_province, postal_code, country_code, latitude, longitude, description, star_rating, user_rating, hotel_link, created_at, updated_at)
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
	now() AS updated_at
FROM venere_hotels h;

--SELECT COUNT(*) FROM provider_hotels
 UPDATE provider_hotels SET geog = ST_MakePoint(longitude, latitude);