-- Function: providers.upsert_provider_hotels_to_hotels_v2(character varying)

-- DROP FUNCTION providers.upsert_provider_hotels_to_hotels_v2(character varying);

CREATE OR REPLACE FUNCTION providers.upsert_provider_hotels_to_hotels_test(provider_name character varying)
  RETURNS void AS
$BODY$/*
  Booking.com script - Update/Insert into hotels_v2 from provider_hotels
  Idempotent, can be run repeatedly (Note other providers could overwrite
  the results of this script though).
*/

/*
  If de-duplication of the input set is required, it could
  be done here via a sub-select that ranks on name_normal 
  and longitude/latitude
*/

/*
  First, are any new hotels in this input set matches for existing hotels?
  Note: This could mean when a full set is grabbed, that a different provider
  becomes 'primary' for a set of provider hotels. Depending on how post-script
  updates are done, this may not be noticable.
*/

UPDATE provider_hotels_test AS p
SET hotel_id = h.id
FROM 
(
  SELECT h.id, p.id AS hotel_provider_id, ROW_NUMBER() OVER(PARTITION BY p.id ORDER BY ST_Distance(p.geog, h.geog) ASC, SIMILARITY(p.name, h.name) DESC) AS Ranking
  FROM hotels_test AS h
  INNER JOIN provider_hotels_test AS p
  --ON p.name_normal = REGEXP_REPLACE(REPLACE(lower(h.name), lower(COALESCE(h.city, '')), ''), '\y(the|hotel|inn|by|apartments|apartment|B&B|and|hostel|villa|de|le|motel|guest|bed|breakfast|suites|spa|")\y|\W', '', 'ig')
  ON SIMILARITY(p.name_normal, REGEXP_REPLACE(LOWER(h.name), '\y(the|hotel|inn|by|apartments|apartment|B&B|and|hostel|villa|de|le|motel|guest|bed|breakfast|suites|spa|tower|towers")\y|\W', '', 'ig')) > 0.75

  AND p.hotel_id IS NULL
  AND 
  (
    ST_Distance(p.geog, h.geog) < 10000
    OR
    (p.country_code = h.country_code AND p.postal_code = h.postal_code)
  )
  AND p.provider = provider_name
) AS H
WHERE p.id = h.hotel_provider_id
AND p.hotel_id IS NULL
AND h.Ranking = 1
AND p.provider = provider_name;

/*
  Second, clean any over-matches and re-match
*/  

SELECT match_provider_hotels_to_hotels_test(provider_name);

/*
  Third, update any existing hotels in the hotels table.
*/

UPDATE hotels_test AS h
SET 
  name = CASE WHEN provider_name = 'expedia' THEN p.name ELSE COALESCE(h.name, p.name) END,
  address = CASE WHEN provider_name = 'expedia' THEN p.address ELSE COALESCE(h.address, p.address) END, 
  city = CASE WHEN provider_name = 'expedia' THEN p.city ELSE COALESCE(h.city, p.city) END, 
  state_province = CASE WHEN provider_name = 'expedia' THEN p.state_province ELSE COALESCE(h.state_province, p.state_province) END, 
  postal_code = CASE WHEN provider_name = 'expedia' THEN p.postal_code ELSE COALESCE(h.postal_code, p.postal_code) END, 
  country_code = CASE WHEN provider_name = 'expedia' THEN p.country_code ELSE COALESCE(h.country_code, p.country_code) END,  
  latitude = CASE WHEN provider_name = 'expedia' THEN p.latitude ELSE COALESCE(h.latitude, p.latitude) END, 
  longitude = CASE WHEN provider_name = 'expedia' THEN p.longitude ELSE COALESCE(h.longitude, p.longitude) END, 
  geog = CASE WHEN provider_name = 'expedia' THEN p.geog ELSE COALESCE(h.geog, p.geog) END, 
  description = CASE WHEN provider_name = 'expedia' THEN p.description ELSE COALESCE(h.description, p.description) END, 
  star_rating = CASE WHEN provider_name = 'expedia' THEN p.star_rating ELSE COALESCE(h.star_rating, p.star_rating) END, 
  amenities = COALESCE(h.amenities,0) | COALESCE(p.amenities,0),  
  --image_url = null, --Unsure if to wipe here, and rely on post-script updates?
  --thumbnail_url = null, --Unsure if to wipe here, and rely on post-script updates?
  user_rating = CASE WHEN provider_name = 'expedia' THEN p.user_rating ELSE COALESCE(h.user_rating, p.user_rating) END, 
  provider_hotel_id = p.id, 
  provider_hotel_ranking = CASE WHEN provider_name = 'booking' THEN p.ranking ELSE COALESCE(h.provider_hotel_ranking, p.ranking) END
FROM provider_hotels_test AS p
WHERE p.hotel_id = h.id
AND p.hotel_id IS NOT NULL
AND p.provider = provider_name;

/*
  Lastly, insert any unmatched
*/

WITH InsertCTE AS
(
  INSERT INTO hotels_test (name, address, city, state_province, postal_code, country_code,  latitude, longitude, geog, description, star_rating, amenities,  image_url, thumbnail_url, user_rating, provider_hotel_id, provider_hotel_ranking)
  SELECT name, address, city, state_province, postal_code, country_code,  latitude, longitude, geog, description, star_rating, amenities,null,null,user_rating, id, ranking
  FROM provider_hotels_test 
  WHERE provider = provider_name
  AND hotel_id IS NULL
  RETURNING id, provider_hotel_id
)

UPDATE provider_hotels_test AS p
SET hotel_id = i.id 
FROM InsertCTE AS I
WHERE I.provider_hotel_id::integer = p.id;

$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
--ALTER FUNCTION providers.upsert_provider_hotels_to_hotels(character varying) OWNER TO postgres;


  
