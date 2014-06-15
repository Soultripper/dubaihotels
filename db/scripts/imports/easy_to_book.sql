INSERT INTO provider_hotels (provider, provider_id, name, address, city, state_province, postal_code, country_code, latitude, longitude, description, star_rating, user_rating, hotel_link, created_at, updated_at, ranking, geog)
SELECT 
  'easy_to_book'                              AS provider,
  h.id                                        AS provider_id,
  h.name                                      AS name, 
  h.address                                   AS address, 
  h.address_city                              AS city, 
  c.province_name                             AS state_province,
  h.zipcode                                   AS postal_code, 
  LOWER(countries.country_iso)                AS country_code,
  h.latitude, 
  h.longitude,  
  d.description                               AS description, 
  CAST(h.stars AS DOUBLE PRECISION)           AS star_rating,
  COALESCE(
    CAST(h.hotel_review_score AS DOUBLE PRECISION) * 20,0) 
                                              AS user_rating,
  h.url                                       AS hotel_link,
  now()                                       AS created_at,
  now()                                       AS updated_at,
  0                                           AS ranking,
  CAST(ST_SetSRID(ST_Point(
    h.longitude, h.latitude), 4326) AS geography)
                                              AS geog
FROM providers.etb_hotels h
LEFT JOIN providers.etb_cities c ON c.id = h.city_id
LEFT JOIN providers.etb_countries countries on countries.id = c.country_id
LEFT JOIN providers.etb_hotel_descriptions d on d.etb_hotel_id = h.id;

-- AMENITIES
UPDATE provider_hotels 
SET amenities = T1.bitmask
FROM (
  SELECT ha.id AS provider_id, ha.flag AS bitmask
  FROM providers.etb_hotel_amenities ha
  WHERE flag IS NOT NULL
) AS T1
WHERE 
  provider_hotels.provider_id = T1.provider_id 
  AND provider_hotels.provider = 'easy_to_book';

  -- IMAGES
DELETE FROM provider_hotel_images WHERE provider = 'easy_to_book';

INSERT INTO provider_hotel_images (url, thumbnail_url, provider, provider_id, default_image)
SELECT image, image, 'etb', etb_hotel_id, TRUE
FROM providers.etb_hotel_images
WHERE size = 'hotel'
GROUP BY image, etb_hotel_id;