DELETE FROM provider_hotels WHERE provider = 'venere';
INSERT INTO provider_hotels (provider, provider_id, name, address, city, state_province, postal_code, country_code, latitude, longitude, description, star_rating, user_rating, hotel_link, created_at, updated_at, ranking, geog)
SELECT 
  'venere'                                AS provider,
  h.id,
  h.name                                  AS name, 
  h.address                               AS address, 
  h.city                                  AS city, 
  h.province                              AS state_province,
  h.zip                                   AS postal_code, 
  LOWER(h.country_iso_code )              AS country_code,
  h.latitude, 
  h.longitude,  
  h.hotel_overview                        AS description, 
  CAST(h.rating AS DOUBLE PRECISION)      AS star_rating,
  COALESCE(
    CAST(h.user_rating AS DOUBLE PRECISION) * 10, 0) 
                                          AS user_rating_normal,
  h.property_url                          AS hotel_link,
  now()                                   AS created_at,
  now()                                   AS updated_at,
  0                                       AS ranking,
  CAST(ST_SetSRID(ST_Point(
    h.longitude, h.latitude), 4326) AS geography)
                                          AS geog
FROM providers.venere_hotels h;

-- AMENITIES
UPDATE provider_hotels
SET amenities = T2.bitmask
FROM (
  SELECT T1.provider_id, SUM(T1.flag) AS bitmask
  FROM
  (
    SELECT DISTINCT 
      ha.venere_hotel_id AS provider_id, 
      a.flag             AS flag
    FROM providers.venere_amenities a
    INNER JOIN providers.venere_hotel_amenities ha ON ha.amenity_id = a.id
    WHERE a.flag IS NOT NULL
    GROUP BY venere_hotel_id, flag
    ORDER BY 1
  ) AS T1
  GROUP BY T1.provider_id
) AS T2
WHERE 
  provider_hotels.provider_id = T2.provider_id 
  AND provider_hotels.provider = 'venere';

-- IMAGES
DELETE FROM provider_hotel_images WHERE provider = 'venere';

INSERT INTO provider_hotel_images (url, thumbnail_url, provider, provider_id, default_image)
SELECT hotel_image_url, hotel_thumb_url, 'venere', id, true
FROM providers.venere_hotels
GROUP BY hotel_image_url, hotel_thumb_url, id
