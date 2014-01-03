--Add Geography
ALTER TABLE splendia_hotels ADD COLUMN geog geography(Point,4326);

--Update Geography
UPDATE splendia_hotels SET geog = CAST(ST_SetSRID(ST_Point(longitude, latitude),4326) As geography)
WHERE (longitude BETWEEN -180 AND 180)
AND (Latitude BETWEEN -90 AND 90);
--Except for hotel 445969 which has an invalid latitude :s

--Index Geography
CREATE INDEX splendia_hotels_geog_idx
  ON splendia_hotels
  USING gist(geog);


--86,090 to match

ALTER TABLE hotels ADD COLUMN splendia_hotel_id integer;


UPDATE splendia_hotels
SET name = REPLACE(name, ', ' || UPPER(city), '')

UPDATE Public.Hotels AS H
SET splendia_hotel_id = SH.Id
FROM
	Public.Splendia_Hotels AS SH
WHERE
	LOWER(H.Name) = LOWER(SH.name)
	AND h.postal_code = SH.postal_code
--Second pass of 10,247
UPDATE Public.Hotels AS H
SET splendia_hotel_id = SH.Id
FROM
	Public.Splendia_Hotels AS SH
WHERE
	LOWER(H.Name) = LOWER(SH.name)
	AND ST_DWithin(SH.geog, H.Geog, 500)
	AND H.splendia_hotel_id IS NULL	

--Third pass of 674
UPDATE Public.Hotels AS H
SET splendia_hotel_id = SH.Id
FROM
	Public.Splendia_Hotels AS SH
WHERE
	LOWER(H.Name) = LOWER(SH.name)
	AND ST_DWithin(SH.geog, H.Geog, 1000)
	AND H.splendia_hotel_id IS NULL

--Fourth pass of 986
UPDATE Public.Hotels AS H
SET splendia_hotel_id = SH.Id
FROM
	Public.Splendia_Hotels AS SH
WHERE
	LOWER(H.Name) = LOWER(SH.name)
	AND ST_DWithin(SH.geog, H.Geog, 10000)
	AND H.splendia_hotel_id IS NULL


select * from splendia_hotels limit 100
select * from hotels limit 100



	