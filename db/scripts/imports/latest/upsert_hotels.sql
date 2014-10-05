-- Function: providers.upsert_provider_hotels_to_hotels_v2(character varying)

-- DROP FUNCTION providers.upsert_provider_hotels_to_hotels_v2(character varying);

CREATE OR REPLACE FUNCTION providers.upsert_provider_hotels_to_hotels(provider_name character varying)
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

UPDATE provider_hotels AS p
SET hotel_id = h.id
FROM 
(
  SELECT h.id, p.id AS hotel_provider_id, 
    ROW_NUMBER() OVER(PARTITION BY p.id ORDER BY SIMILARITY(p.name_normal, h.name_normal) DESC, SIMILARITY(p.address, h.address) DESC, ST_Distance(p.geog, h.geog) ASC) AS Ranking
  FROM hotels AS h
  INNER JOIN provider_hotels AS p
  --ON p.name_normal = REGEXP_REPLACE(REPLACE(lower(h.name), lower(COALESCE(h.city, '')), ''), '\y(the|hotel|inn|by|apartments|apartment|B&B|and|hostel|villa|de|le|motel|guest|bed|breakfast|suites|spa|")\y|\W', '', 'ig')
  --ON p.name_normal = REGEXP_REPLACE(h.name, '\y(the|hotel|inn|by|apartments|apartment|B&B|and|hostel|villa|de|le|motel|guest|bed|breakfast|suites|spa|")\y|\W', '', 'ig')

  ON (ST_Distance(p.geog, h.geog) < 1000  AND SIMILARITY(p.name_normal, h.name_normal) >= within_range(p.geog, h.geog))


  AND p.hotel_id IS NULL
  AND p.provider = provider_name
) AS H
WHERE p.id = h.hotel_provider_id
AND p.hotel_id IS NULL
AND h.Ranking = 1
AND p.provider = provider_name;

/*
  Second, clean any over-matches and re-match
*/  

SELECT match_provider_hotels_to_hotels(provider_name);

/*
  Third, update any existing hotels in the hotels table.
*/

UPDATE hotels AS h
SET 
  --name = CASE WHEN provider_name = 'expedia' THEN p.name ELSE h.name END,
  address = COALESCE(h.address, p.address), 
  city = COALESCE(h.city, p.city), 
  state_province = COALESCE(h.state_province, p.state_province), 
  postal_code = COALESCE(h.postal_code, p.postal_code), 
  country_code = LOWER(COALESCE(h.country_code, p.country_code)),  
  --latitude = CASE WHEN provider_name = 'expedia' THEN p.latitude ELSE COALESCE(h.latitude, p.latitude) END, 
  --longitude = CASE WHEN provider_name = 'expedia' THEN p.longitude ELSE COALESCE(h.longitude, p.longitude) END, 
  --geog = CASE WHEN provider_name = 'expedia' THEN p.geog ELSE COALESCE(h.geog, p.geog) END, 
  description = COALESCE(h.description, p.description), 
  star_rating = CASE WHEN COALESCE(h.star_rating,0) = 0 THEN coalesce(p.star_rating,0) else h.star_rating END, 
  amenities = COALESCE(h.amenities,0) | COALESCE(p.amenities,0),  
  --image_url = null, --Unsure if to wipe here, and rely on post-script updates?
  --thumbnail_url = null, --Unsure if to wipe here, and rely on post-script updates?
    user_rating = CASE WHEN COALESCE(h.user_rating,0) = 0 THEN coalesce(p.user_rating,0) else h.user_rating END,
  --provider_hotel_id = p.id, 
  provider_hotel_ranking = CASE WHEN provider_name = 'booking' THEN p.ranking ELSE COALESCE(h.provider_hotel_ranking, p.ranking) END
FROM provider_hotels AS p
WHERE p.hotel_id = h.id
AND p.hotel_id IS NOT NULL
AND p.provider = provider_name;

/*
  Lastly, insert any unmatched
*/

WITH InsertCTE AS
(
  INSERT INTO hotels (name, address, city, state_province, postal_code, country_code,  latitude, longitude, geog, description, star_rating, amenities,  image_url, thumbnail_url, user_rating, provider_hotel_id, provider_hotel_ranking, name_normal)
  SELECT name, address, city, state_province, postal_code, country_code,  latitude, longitude, geog, description, star_rating, amenities,null,null,user_rating, id, ranking, normalise_name(name)
  FROM provider_hotels 
  WHERE provider = provider_name
  AND hotel_id IS NULL
  RETURNING id, provider_hotel_id
)

UPDATE provider_hotels AS p
SET hotel_id = i.id 
FROM InsertCTE AS I
WHERE I.provider_hotel_id::integer = p.id;

$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
--ALTER FUNCTION providers.upsert_provider_hotels_to_hotels(character varying)
--  OWNER TO postgres;


  
