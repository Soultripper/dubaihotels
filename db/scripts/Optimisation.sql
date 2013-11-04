/*
	Optimisation 1A: Create a copy of the hotels table,
	this one would be used for future matching. The plan
	would be to insert from public.hotels to utility.hotels,
	do the work, then copy the ean_hotel_id back on a pk->pk join.
*/

CREATE TABLE utility.hotels
(
  id integer NOT NULL,
  name character varying(255),
  address character varying(255),
  city character varying(255),
  state_province character varying(255),
  postal_code character varying(255),
  country_code character varying(255),
  latitude double precision,
  longitude double precision,
  star_rating double precision,
  high_rate double precision,
  low_rate double precision,
  check_in_time character varying(255),
  check_out_time character varying(255),
  property_currency character varying(255),
  ean_hotel_id integer,
  booking_hotel_id integer,
  nameaddress character varying(1024),
  weighted_ean_hotel_id integer,
  weighted_value_ean_hotel_id integer,
  description text,
  amenities integer,
  geog geography(Point,4326),
  CONSTRAINT hotels_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE utility.hotels
  OWNER TO u1uf61dvp27blk;

/*
	Optimisation 1B: Remove the columns on the hotels
	table used for matching, as they are wide.
*/

DROP INDEX hotels_nameaddress_trgm_idx;
ALTER TABLE hotels DROP COLUMN nameaddress;
ALTER TABLE hotels DROP COLUMN weighted_ean_hotel_id;
ALTER TABLE hotels DROP COLUMN weighted_value_ean_hotel_id;

/*
	Optimisation 2: The search

	Looking into the queries running, the main problem is the
	equivalent of "SELECT COUNT(*) FROM "hotels"  WHERE (city ILIKE 'Cromer' and country_code = 'gb')"
	Due to the ILIKE there is no good index. Either use LIKE or index a LOWER(city) column.
*/

CREATE INDEX hotels_city_country_code_idx
  ON hotels
  USING btree
  (city COLLATE pg_catalog."default", country_code COLLATE pg_catalog."default");
  
SELECT * FROM "hotels"  WHERE (city ILIKE 'Cromer' and country_code = 'gb'); --When we use ILIKE it's a costly index bitmap scan 
SELECT * FROM "hotels"  WHERE (city LIKE 'Cromer' and country_code = 'gb'); -- When we just use LIKE we get an index scan

/*
	Optimisation 3: The slug
	Slug lookup to city/country
*/
CREATE INDEX locations_slug_idx
  ON locations
  USING btree
  (slug COLLATE pg_catalog."default");