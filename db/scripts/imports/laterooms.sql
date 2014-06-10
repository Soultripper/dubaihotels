-- HOTELS
DELETE FROM provider_hotels WHERE provider = 'laterooms';
INSERT INTO provider_hotels (provider, provider_id, name, address, city, state_province, postal_code, country_code, latitude, longitude, description, star_rating, user_rating, hotel_link, created_at, updated_at, ranking, geog)
SELECT 
  'laterooms'                               AS provider,
  h.id                                      AS provider_id,
  h.name                                    AS name, 
  h.address1                                AS address, 
  h.city, 
  h.county,
  h.postcode                                AS postal_code, 
  LOWER(h.country_iso)                      AS country_code,
  h.latitude, 
  h.longitude,  
  h.description                             AS description, 
  CASE left(h.star_rating, 1) 
    WHEN 'N' THEN NULL 
    WHEN 'A' THEN NULL 
    WHEN 'B' THEN NULL 
    WHEN 'T' THEN NULL 
    ELSE 
      CAST(left(h.star_rating, 1) AS DOUBLE PRECISION) 
    END                                     AS star_rating,
  COALESCE(
    CAST(score_out_of_6 AS DOUBLE PRECISION) * 16.666,0) 
                                            AS user_rating,
  h.url                                     AS hotel_link,
  now()                                     AS created_at,
  now()                                     AS updated_at,
  0                                         AS ranking,
  CAST(ST_SetSRID(ST_Point(
    h.longitude, h.latitude), 4326) AS geography)
                                            AS geog
FROM late_rooms_hotels h;

-- AMENITIES
UPDATE provider_hotels
SET amenities = T2.bitmask
FROM (
  SELECT T1.provider_id, SUM(T1.flag) AS bitmask
  FROM (
    SELECT DISTINCT 
      ha.laterooms_hotel_id as provider_id, 
      a.flag
    FROM late_rooms_hotel_amenities ha
    INNER JOIN late_rooms_amenities a on a.description = ha.amenity
    WHERE a.flag IS NOT NULL
    GROUP BY ha.laterooms_hotel_id, a.flag
    ORDER BY 1
  ) AS T1
  GROUP BY T1.provider_id
) AS T2
WHERE 
  provider_hotels.provider_id = T2.provider_id 
  AND provider_hotels.provider = 'laterooms'; 

-- IMAGES
DELETE FROM provider_hotel_images where provider = 'laterooms';

INSERT INTO provider_hotel_images (url, thumbnail_url, provider, provider_id, default_image)
SELECT image_url, image_url, 'laterooms', laterooms_hotel_id, default_image
FROM late_rooms_hotel_images
GROUP BY image_url, laterooms_hotel_id, default_image;