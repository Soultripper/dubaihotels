SELECT COUNT(*)  FROM Hotels_V2
SELECT COUNT(*)  FROM provider_hotels

SELECT id, hotel_id, name_normal, p.latitude, p.longitude, *
FROM provider_hotels AS p
WHERE P.hotel_id IS NOT NULL
ORDER BY name_normal, latitude, longitude
LIMIT 10000

SELECT id, hotel_id, name_normal, latitude, longitude, *
FROM provider_hotels AS p
WHERE P.hotel_id IS NOT NULL
AND Country_Code = 'gb'
ORDER BY latitude, longitude
LIMIT 10000


/*
TRUNCATE TABLE hotels;
UPDATE provider_hotels SET Hotel_Id = NULL;

SELECT * FROM pg_locks
*/
	SELECT h.id AS hotel_v2_id, p.id AS hotel_provider_id, ROW_NUMBER() OVER(PARTITION BY p.id ORDER BY ST_Distance(p.geog, h.geog)) AS Ranking, ST_Distance(p.geog, h.geog)
	FROM hotels_v2 AS h
	INNER JOIN provider_hotels AS p
	ON p.name_normal = REGEXP_REPLACE(REPLACE(lower(name), lower(city), ''), '\y(the|hotel|inn|by|B&B|and|hostel|villa|de|le|motel|guest|bed|breakfast|spa|")\y|\W', '', 'ig')
	--AND ST_Distance(p.geog, h.geog) < 10000
	AND p.provider = 'expedia'
	AND p.name_normal = 'aalborg'

SELECT provider, COUNT(*) FROM provider_hotels WHERE name_normal IS NULL GROUP BY provider 


SELECT * FROM provider_hotels WHERE provider = 'laterooms'
/*
UPDATE provider_hotels 
SET name_normal = REGEXP_REPLACE(REPLACE(lower(name), lower(COALESCE(city, '')), ''), '\y(the|hotel|inn|by|apartments|apartment|B&B|and|hostel|villa|de|le|motel|guest|bed|breakfast|suites|spa|")\y|\W', '', 'ig')
WHERE provider = 'laterooms'
AND name_normal IS NULL

UPDATE provider_hotels 
SET name_normal = REGEXP_REPLACE(lower(name), '\y(the|hotel|inn|by|apartments|apartment|B&B|and|hostel|villa|de|le|motel|guest|bed|breakfast|suites|spa|")\y|\W', '', 'ig')
WHERE coalesce(name_normal,'') = ''
*/


SELECT REGEXP_REPLACE(REPLACE(lower(name), lower(COALESCE(city, '')), ''), '\y(the|hotel|inn|by|apartments|apartment|B&B|and|hostel|villa|de|le|motel|guest|bed|breakfast|suites|spa|")\y|\W', '', 'ig'),* 
FROM provider_hotels WHERE name_normal IS NULL
