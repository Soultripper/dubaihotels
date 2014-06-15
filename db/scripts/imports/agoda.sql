-- PROVIDER HOTELS

DELETE FROM provider_hotels where provider = 'agoda';

INSERT INTO provider_hotels (provider, provider_id, name, address, city, state_province, postal_code, country_code, latitude, longitude, description, star_rating, user_rating, hotel_link, created_at, updated_at, ranking, geog)
SELECT 
  'agoda' AS provider,
  h.id                                        AS provider_id,
  h.hotel_name                                AS name, 
  COALESCE(h.addressline1,'') || COALESCE(
    COALESCE(', ' || h.addressline2, ''))     AS address, 
  h.city, 
  h.state                                     AS state_province,
  h.zipcode                                   AS postal_code, 
  lower(h.countryisocode)                     AS country_code,
  h.latitude, 
  h.longitude,  
  h.overview                                  AS description, 
  CAST(h.star_rating AS DOUBLE PRECISION)     AS star_rating, 
  COALESCE(
    CAST(h.rating_average AS DOUBLE PRECISION) * 10, 0) 
                                              AS user_rating,
  h.url                                       AS hotel_link,
  now()                                       AS created_at,
  now()                                       AS updated_at,
  0                                           AS ranking,
  CAST(ST_SetSRID(ST_Point(
    h.longitude, h.latitude), 4326) AS geography)
                                              AS geog
FROM providers.agoda_hotels h;

-- UPDATE AMENITIES
UPDATE provider_hotels
SET amenities = T2.bitmask
FROM (
  SELECT T1.agoda_hotel_id, SUM(T1.flag) AS bitmask
  FROM (
    SELECT DISTINCT 
      ha.agoda_hotel_id, 
      a.flag
    FROM providers.agoda_hotel_amenities ha
    INNER JOIN providers.agoda_amenities a on a.description = ha.name
    WHERE a.flag IS NOT NULL
    GROUP BY ha.agoda_hotel_id, a.flag
    ORDER BY 1
  ) AS T1
  GROUP BY T1.agoda_hotel_id
) AS T2
WHERE 
  provider_hotels.provider_id = T2.agoda_hotel_id 
  AND provider_hotels.provider = 'agoda'; 

-- IMAGES
DELETE FROM provider_hotel_images where provider = 'agoda';

INSERT INTO provider_hotel_images (url, thumbnail_url, provider, provider_id)
SELECT image_url, image_url, 'agoda', agoda_hotel_id
FROM providers.agoda_hotel_images
GROUP BY image_url, agoda_hotel_id;

UPDATE provider_hotel_images p
SET default_image = true
FROM
(
  SELECT id, ROW_NUMBER() OVER(PARTITION BY provider_id ORDER BY default_image DESC, id ASC) AS row_number
  FROM provider_hotel_images
  WHERE provider = 'agoda'
) AS T1
WHERE T1.id = p.id AND T1.row_number = 1;