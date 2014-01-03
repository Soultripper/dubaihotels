-- Table: splendia_hotels

-- DROP TABLE splendia_hotels;

CREATE TABLE splendia_hotels
(
  id serial NOT NULL,
  name character varying(255),
  country character varying(255),
  city character varying(255),
  city_id integer,
  state_province_name character varying(255),
  state_province_code character varying(255),
  street character varying(255),
  postal_code character varying(255),
  stars character varying(255),
  club character varying(255),
  product_url text,
  facilities text,
  description text,
  latitude double precision,
  longitude double precision,
  hotel_currency character varying(255),
  category_id character varying(255),
  price double precision,
  original_price double precision,
  product_name character varying(255),
  product_id integer,
  currency character varying(255),
  stars_rating character varying(255),
  small_image character varying(255),
  big_image character varying(255),
  other_services text,
  reviews integer,
  rating character varying(255),
  category character varying(255),
  offers text,
  CONSTRAINT splendia_hotels_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE splendia_hotels
  OWNER TO "Sky";
