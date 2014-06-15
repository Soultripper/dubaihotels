


-- PROVIDER HOTELS
-- Booking rating is out of 10
DELETE FROM provider_hotels where provider = 'booking';
INSERT INTO provider_hotels (provider, provider_id, name, address, city, state_province, postal_code, country_code, latitude, longitude, description, star_rating, user_rating, hotel_link, created_at, updated_at, ranking, geog)
SELECT 
  'booking'                                AS provider,
  h.id                                     AS provider_id,
  h.name, 
  h.address, 
  h.city, 
  h.district                               AS state_province,
  h.zip                                    AS postal_code, 
  lower(h.country_code)                    AS country_code,
  h.latitude, 
  h.longitude,  
  d.description, 
  h.classification                         AS star_rating, 
  COALESCE(CAST(h.review_score 
    AS DOUBLE PRECISION) * 10,0)           AS user_rating,
  h.url                                    AS hotel_link,
  now()                                    AS created_at,
  now()                                    AS updated_at,
  ranking                                  AS ranking,
  CAST(ST_SetSRID(ST_Point(
    h.longitude, h.latitude), 4326) AS geography)
                                           AS geog
FROM providers.booking_hotels h
LEFT JOIN providers.booking_hotel_descriptions d ON d.booking_hotel_id = h.id;

-- UPDATE AMENITIES

-- UPDATE booking_amenities SET flag = 1 WHERE lower(name) like '%wifi%'
-- UPDATE booking_amenities SET flag = 4 WHERE name = 'Children''s playground' OR name = 'Babysitting/child services' OR name = 'Kids'' club' 
-- UPDATE booking_amenities SET flag = 8 WHERE lower(name) like '%parking%';
-- UPDATE booking_amenities SET flag = 16 WHERE name = 'Fitness centre' 
-- UPDATE booking_amenities SET flag = 64 WHERE name = 'Non-smoking rooms' OR name = 'Non-smoking throughout' OR name = 'Designated smoking area'
-- UPDATE booking_amenities SET flag =128 WHERE name = 'Pets allowed'
-- UPDATE booking_amenities SET flag = 256 WHERE lower(name) like '%pool%' 
-- UPDATE booking_amenities SET flag = 512 WHERE lower(name) like '%restaurant%';
-- UPDATE booking_amenities SET flag =1024 WHERE name like 'Spa and wellness centre';

UPDATE provider_hotels
SET amenities = T2.bitmask
FROM (
  SELECT T1.booking_hotel_id, SUM(T1.flag) AS bitmask
  FROM (
    SELECT DISTINCT 
      bha.booking_hotel_id, 
      ba.flag
    FROM providers.booking_amenities ba
    INNER JOIN providers.booking_hotel_amenities bha on bha.booking_facility_type_id = ba.id
    WHERE ba.flag IS NOT NULL
    GROUP BY bha.booking_hotel_id, ba.flag
    ORDER BY 1
  ) AS T1
  GROUP BY T1.booking_hotel_id
) AS T2
WHERE 
  provider_hotels.provider_id = T2.booking_hotel_id 
  AND provider_hotels.provider = 'booking'; 

-- PROVIDER HOTEL IMAGES
DELETE FROM provider_hotel_images where provider = 'booking';

INSERT INTO provider_hotel_images (url, thumbnail_url, provider, provider_id)
SELECT url_max_300, url_square60, 'booking', booking_hotel_id
FROM providers.booking_hotel_images
GROUP BY url_max_300, url_square60, booking_hotel_id;

UPDATE provider_hotel_images p
SET default_image = true
FROM
(
  SELECT id, ROW_NUMBER() OVER(PARTITION BY provider_id ORDER BY default_image DESC, id ASC) AS row_number
  FROM provider_hotel_images
  WHERE provider = 'booking'
) AS t1
WHERE t1.id = p.id AND t1.row_number = 1;

