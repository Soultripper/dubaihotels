-- SET geog (may not be necssary as populated in main imports per provider)
UPDATE provider_hotels SET geog =   CAST(ST_SetSRID(ST_Point(longitude, latitude), 4326) AS geography) WHERE geog IS NULL;

-- UPDATE NORMAL NAME
TRUNCATE TABLE providers.hotel_names;

INSERT INTO providers.hotel_names
SELECT id, name, REPLACE(LOWER(name), LOWER(city), '') , REPLACE(LOWER(name), LOWER(city), '') FROM provider_hotels;

-- if hotel name is same as the city then put back
UPDATE providers.hotel_names 
SET lower_name = LOWER(name), normal_name = LOWER(name)
WHERE COALESCE(lower_name,'') = '';

UPDATE providers.hotel_names 
SET normal_name = REGEXP_REPLACE(lower_name, '\y(the|hotel|inn|by|apartments|apartment|B&B|and|hostel|villa|de|le|motel|guest|bed|breakfast|suites|spa|")\y|\W', '', 'ig');

-- if hotel name is empty, put back to name
UPDATE providers.hotel_names 
SET normal_name = LOWER(name)
WHERE COALESCE(normal_name,'') = '';

UPDATE provider_hotels
SET name_normal = T1.normal_name
FROM (
  SELECT id, normal_name FROM providers.hotel_names
) AS T1
WHERE provider_hotels.id = T1.id

SELECT pg_terminate_backend(pid)
    FROM pg_stat_activity
    WHERE datname = 'd1ikhokbp9k9b9'
      AND pid <> pg_backend_pid()
      AND state = 'idle'
      AND state_change < current_timestamp - INTERVAL '5' MINUTE;