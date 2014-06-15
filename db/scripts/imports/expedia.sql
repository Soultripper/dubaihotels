-- PROVIDER HOTELS

DELETE FROM provider_hotels where provider = 'expedia';
INSERT INTO provider_hotels (provider, provider_id, name, address, city, state_province, postal_code, country_code, latitude, longitude, description, star_rating, user_rating, hotel_link, created_at, updated_at, ranking, geog)
SELECT 
  'expedia'                                   AS provider,
  h.id                                        AS provider_id,
  h.name, 
  COALESCE(h.address1,'') 
    || COALESCE(COALESCE(', ' || h.address2, '') 
    || COALESCE(', ' || h.state_province),'') AS address, 
  h.city, 
  h.state_province,
  h.postal_code, 
  LOWER(h.country)                            AS country_code,
  h.latitude, 
  h.longitude,  
  d.description, 
  h.star_rating, 
  null  AS user_rating,
  null  AS hotel_link,
  now() AS created_at,
  now() AS updated_at,
  sequence_number                             AS ranking,
  CAST(ST_SetSRID(ST_Point(
    h.longitude, h.latitude), 4326) AS geography)
                                              AS geog
FROM providers.ean_hotels h
LEFT JOIN providers.ean_hotel_descriptions d ON d.ean_hotel_id = h.id;

-- UPDATE AMENITIES
UPDATE provider_hotels
SET amenities = T2.bitmask
FROM (
  SELECT T1.provider_id, SUM(T1.flag) AS bitmask
  FROM (
    SELECT DISTINCT
      EHAL.ean_hotel_id AS provider_id,
      HA.flag
    FROM
      providers.ean_hotel_amenities AS EHAL 
      INNER JOIN providers.ean_amenities AS EHA ON EHA.attribute_id = EHAL.attribute_id
      INNER JOIN hotel_amenities AS HA ON HA.id = EHA.hotel_amenities_id
    GROUP BY ean_hotel_id, flag
    ORDER BY 1
  ) AS T1
  GROUP BY T1.provider_id
)AS T2
WHERE
  provider_hotels.provider_id = T2.provider_id 
  AND provider_hotels.provider = 'expedia';
  
-- PROVIDER HOTEL IMAGES
--  update ean_hotel_images set default_image = true where caption = 'Exterior'
DELETE FROM provider_hotel_images where provider = 'expedia';
 
INSERT INTO provider_hotel_images (url, thumbnail_url, provider, provider_id, default_image, width, height)
SELECT url, thumbnail_url, 'expedia', ean_hotel_id, 
      CASE WHEN caption = 'Exterior' 
      THEN true 
      ELSE false 
      END as default_image, 
      width, 
      height
FROM providers.ean_hotel_images
GROUP BY url, thumbnail_url, ean_hotel_id, caption, default_image, width, height;

UPDATE provider_hotel_images p
SET default_image = true
FROM
(
  SELECT id, ROW_NUMBER() OVER(PARTITION BY provider_id ORDER BY default_image DESC, id ASC) AS row_number
  FROM provider_hotel_images
  WHERE provider = 'expedia'
) AS t1
WHERE t1.id = p.id AND t1.row_number = 1;