SELECT * FROM booking_hotel_images LIMIT 100
SELECT * FROM agoda_hotel_images LIMIT 100
SELECT * FROM ean_hotel_images LIMIT 100
SELECT * FROM etb_hotel_images LIMIT 100
SELECT * FROM late_rooms_hotel_images LIMIT 100
SELECT * FROM splendia_hotels LIMIT 100
SELECT * FROM venere_hotels LIMIT 100


-- DROP TABLE provider_hotel_images;

CREATE TABLE provider_hotel_images
(
  id serial NOT NULL,
  hotel_id integer,
  url character varying(255),
  width integer,
  height integer,
  byte_size integer,
  thumbnail_url character varying(255),
  default_image boolean,
  remote_url character varying(255),
  cdn character varying(255),
  provider character varying(255),
  provider_id integer,
  CONSTRAINT provider_hotel_images_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);


-- BOOKING
INSERT INTO provider_hotel_images (url, thumbnail_url, provider, provider_id)
SELECT url_max_300, url_square60, 'booking', booking_hotel_id
FROM booking_hotel_images
GROUP BY url_max_300, url_square60, booking_hotel_id;

-- AGODA
INSERT INTO provider_hotel_images (url, thumbnail_url, provider, provider_id)
SELECT image_url, image_url, 'agoda', agoda_hotel_id
FROM agoda_hotel_images
GROUP BY image_url, agoda_hotel_id;

-- EXPEDIA
-- 	update ean_hotel_images set default_image = true where caption = 'Exterior'

INSERT INTO provider_hotel_images (url, thumbnail_url, provider, provider_id, default_image, width, height)
SELECT url, thumbnail_url, 'expedia', ean_hotel_id, default_image, width, height
FROM ean_hotel_images
GROUP BY url, thumbnail_url, ean_hotel_id,default_image, width, height;

-- 	update provider_hotel_images phi set default_image = true 
-- 	from (select *  from ean_hotel_images where default_image = true) as t1
-- 	where phi.provider = 'expedia' and phi.provider_id = t1.ean_hotel_id and phi.url = t1.url

-- EasyToBook
delete from provider_hotel_images where provider = 'etb'
INSERT INTO provider_hotel_images (url, thumbnail_url, provider, provider_id, default_image)
SELECT image, image, 'etb', etb_hotel_id, true
FROM etb_hotel_images
WHERE size = 'hotel'
GROUP BY image, etb_hotel_id;

-- Laterooms
INSERT INTO provider_hotel_images (url, thumbnail_url, provider, provider_id, default_image)
SELECT image_url, image_url, 'laterooms', laterooms_hotel_id, default_image
FROM late_rooms_hotel_images
GROUP BY image_url, laterooms_hotel_id, default_image;

-- Splendia
delete from provider_hotel_images where provider = 'splendia';
INSERT INTO provider_hotel_images (url, thumbnail_url, provider, provider_id, default_image)
SELECT big_image, small_image, 'splendia', id, true
FROM splendia_hotels
GROUP BY big_image, small_image,  id;

-- Venere
delete from provider_hotel_images where provider = 'venere';

INSERT INTO provider_hotel_images (url, thumbnail_url, provider, provider_id, default_image)
SELECT hotel_image_url, hotel_thumb_url, 'venere', id, true
FROM venere_hotels
GROUP BY hotel_image_url, hotel_thumb_url, id




--------- 

UPDATE provider_hotel_images p
SET default_image = true
FROM
(
	SELECT id, ROW_NUMBER() OVER(PARTITION BY provider_id ORDER BY default_image DESC, id ASC) AS row_number
	FROM provider_hotel_images
) AS t1
WHERE t1.id = p.id AND t1.row_number = 1 AND default_image IS NULL

-----------

-- expedia 
UPDATE hotels_temp SET image_url = t1.url, thumbnail_url = t1.thumbnail_url
FROM( SELECT * FROM provider_hotel_images WHERE default_image = true AND provider = 'expedia') AS t1
WHERE ean_hotel_id = t1.provider_id AND image_url IS NULL;;

-- agoda
UPDATE hotels_temp SET image_url = t1.url, thumbnail_url = t1.thumbnail_url
FROM( SELECT * FROM provider_hotel_images WHERE default_image = true AND provider = 'agoda') AS t1
WHERE agoda_hotel_id = t1.provider_id AND image_url IS NULL;

-- laterooms
UPDATE hotels_temp SET image_url = t1.url, thumbnail_url = t1.thumbnail_url
FROM( SELECT * FROM provider_hotel_images WHERE default_image = true AND provider = 'laterooms') AS t1
WHERE laterooms_hotel_id = t1.provider_id AND image_url IS NULL;

-- etb
UPDATE hotels_temp SET image_url = t1.url, thumbnail_url = t1.thumbnail_url
FROM( SELECT * FROM provider_hotel_images WHERE default_image = true AND provider = 'etb') AS t1
WHERE etb_hotel_id = t1.provider_id AND image_url IS NULL;

-- splendia
UPDATE hotels_temp SET image_url = t1.url, thumbnail_url = t1.thumbnail_url
FROM( SELECT * FROM provider_hotel_images WHERE default_image = true AND provider = 'splendia') AS t1
WHERE splendia_hotel_id = t1.provider_id AND image_url IS NULL;

-- venere
UPDATE hotels_temp SET image_url = t1.url, thumbnail_url = t1.thumbnail_url
FROM( SELECT * FROM provider_hotel_images WHERE default_image = true AND provider = 'venere') AS t1
WHERE venere_hotel_id = t1.provider_id AND image_url IS NULL;

-- booking
UPDATE hotels_temp SET image_url = t1.url, thumbnail_url = t1.thumbnail_url
FROM( SELECT * FROM provider_hotel_images WHERE default_image = true AND provider = 'booking') AS t1
WHERE booking_hotel_id = t1.provider_id AND image_url IS NULL;



