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
SET hotel_id = h.hotel_v2_id
FROM 
(
	SELECT h.id AS hotel_v2_id, p.id AS hotel_provider_id, ROW_NUMBER() OVER(PARTITION BY p.id ORDER BY ST_Distance(p.geog, h.geog)) AS Ranking
	FROM hotels AS h
	INNER JOIN provider_hotels AS p
	ON p.name_normal = REGEXP_REPLACE(REPLACE(lower(h.name), lower(COALESCE(h.city, '')), ''), '\y(the|hotel|inn|by|apartments|apartment|B&B|and|hostel|villa|de|le|motel|guest|bed|breakfast|suites|spa|")\y|\W', '', 'ig')
	AND p.hotel_id IS NULL
	AND ST_Distance(p.geog, h.geog) < 10000
	AND p.provider = provider_name
) AS H
WHERE p.id = h.hotel_provider_id
AND p.hotel_id IS NULL
AND h.Ranking = 1
AND p.provider = provider_name;

/*
	Second, update any existing hotels in the hotels_v2 table.
*/

UPDATE hotels AS h
SET 
	name = COALESCE(h.name,p.name),
	address = COALESCE(h.address,p.address), 
	city = COALESCE(h.city, p.city), 
	state_province = COALESCE(h.state_province, p.state_province), 
	postal_code = COALESCE(h.postal_code, p.postal_code), 
	country_code = COALESCE(h.country_code, p.country_code),  
	latitude = COALESCE(h.latitude, p.latitude), 
	longitude = COALESCE(h.longitude, p.longitude), 
	geog = COALESCE(h.geog, p.geog), 
	description = COALESCE(h.description, p.description), 
	star_rating = COALESCE(h.star_rating, p.star_rating), 
	amenities = COALESCE(h.amenities,0) | COALESCE(p.amenities,0),  
	image_url = null, --Unsure if to wipe here, and rely on post-script updates?
	thumbnail_url = null, --Unsure if to wipe here, and rely on post-script updates?
	user_rating = COALESCE(h.user_rating, p.user_rating), 
	provider_hotel_id = COALESCE(h.provider_hotel_id, p.id), 
	provider_hotel_ranking = COALESCE(h.provider_hotel_ranking, p.ranking)
FROM provider_hotels AS p
WHERE p.hotel_id = h.id
AND p.hotel_id IS NOT NULL
AND p.provider = provider_name;


/*
	Third, insert any new hotels into the hotels_v2 table
*/

WITH InsertCTE AS
(
	INSERT INTO hotels (name, address, city, state_province, postal_code, country_code,  latitude, longitude, geog, description, star_rating, amenities,  image_url, thumbnail_url, user_rating, provider_hotel_id, provider_hotel_ranking)
	SELECT name, address, city, state_province, postal_code, country_code,  latitude, longitude, geog, description, star_rating, amenities,null,null,user_rating, id, ranking
	FROM provider_hotels 
	WHERE provider = provider_name
	AND hotel_id IS NULL
	RETURNING id, provider_hotel_id
)

UPDATE provider_hotels AS p
SET hotel_id = i.id 
FROM InsertCTE AS I
WHERE I.provider_hotel_id::integer = p.id
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
--ALTER FUNCTION providers.upsert_provider_hotels_to_hotels(character varying)
  --OWNER TO postgres;
