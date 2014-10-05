DELETE FROM provider_hotels where provider = 'splendia';
INSERT INTO provider_hotels (provider, provider_id, name, address, city, state_province, postal_code, country_code, latitude, longitude, description, star_rating, user_rating, hotel_link, created_at, updated_at, ranking, geog)
SELECT 
  'splendia'                                        AS provider,
  h.id                                              AS provider_id,
  h.name                                            AS name, 
  h.street                                          AS address, 
  h.city                                            AS city, 
  h.state_province_name                             AS state_province,
  h.postal_code                                     AS postal_code, 
  LOWER(countries.iso2 )                    AS country_code,
  h.latitude, 
  h.longitude,  
  h.description                                     AS description, 
  CASE substr(h.stars,2,1) 
    WHEN '' THEN NULL 
    ELSE CAST(substr(h.stars,2,1) AS DOUBLE PRECISION) 
  END                                               AS star_rating,
  COALESCE(
    CAST(REPLACE(h.rating,'%','') AS DOUBLE PRECISION),0) 
                                                    AS user_rating,
  h.product_url                                     AS hotel_link,
  now()                                             AS created_at,
  now()                                             AS updated_at,
  0                                                 AS ranking,
  CAST(ST_SetSRID(ST_Point(
    h.longitude, h.latitude), 4326) AS geography)
                                                    AS geog
FROM providers.splendia_hotels h
LEFT JOIN providers.country_codes countries ON lower(countries.name) = lower(h.country)

-- AMENITIES
UPDATE provider_hotels
SET amenities = T2.bitmask
FROM (
  SELECT T1.provider_id, SUM(T1.flag) AS bitmask
  FROM(
    SELECT DISTINCT 
      ha.splendia_hotel_id      AS provider_id, 
      a.flag                    AS flag
    FROM providers.splendia_hotel_amenities ha
    INNER JOIN providers.splendia_amenities a on a.description = ha.amenity
    WHERE a.flag IS NOT NULL
    GROUP BY splendia_hotel_id, flag
    ORDER BY 1
  ) AS T1
  GROUP BY T1.provider_id
) AS T2
WHERE 
  provider_hotels.provider_id = T2.provider_id 
  AND provider_hotels.provider = 'splendia';

-- IMAGES
DELETE FROM provider_hotel_images WHERE provider = 'splendia';

INSERT INTO provider_hotel_images (url, thumbnail_url, provider, provider_id, default_image)
SELECT big_image, small_image, 'splendia', id, true
FROM providers.splendia_hotels
GROUP BY big_image, small_image,  id;
