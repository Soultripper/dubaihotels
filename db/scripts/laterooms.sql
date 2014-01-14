--Add Geography
ALTER TABLE late_rooms_hotels ADD COLUMN geog geography(Point,4326);

--Update Geography
UPDATE late_rooms_hotels SET geog = CAST(ST_SetSRID(ST_Point(longitude, latitude),4326) As geography)
WHERE (longitude BETWEEN -180 AND 180)
AND (Latitude BETWEEN -90 AND 90);
--Except for hotel 445969 which has an invalid latitude :s

--Index Geography
CREATE INDEX late_rooms_hotels_geog_idx
  ON late_rooms_hotels
  USING gist(geog);

--38003 to match

--Initial update of 15470
UPDATE Public.Hotels AS H
SET laterooms_Hotel_Id = AH.Id
FROM
	Public.late_rooms_Hotels AS AH
WHERE
	LOWER(H.postal_code) = LOWER(AH.postcode)
	AND LOWER(H.Name) = LOWER(AH.name)

--Second pass of 3681
UPDATE Public.Hotels AS H
SET laterooms_Hotel_Id = AH.Id
FROM
	Public.late_rooms_Hotels AS AH
WHERE
	LOWER(H.Name) = LOWER(AH.name)
	AND ST_DWithin(AH.geog, H.Geog, 500)
	AND H.laterooms_Hotel_Id IS NULL	

--Third pass of 206
UPDATE Public.Hotels AS H
SET laterooms_Hotel_Id = AH.Id
FROM
	Public.late_rooms_Hotels AS AH
WHERE
	LOWER(H.Name) = LOWER(AH.Name)
	AND ST_DWithin(AH.geog, H.Geog, 1000)
	AND H.laterooms_Hotel_Id IS NULL

--Fourth pass of 427
UPDATE Public.Hotels AS H
SET laterooms_Hotel_Id = AH.Id
FROM
	Public.late_rooms_Hotels AS AH
WHERE
	LOWER(H.Name) = LOWER(AH.name)
	AND ST_DWithin(AH.geog, H.Geog, 10000)
	AND H.laterooms_Hotel_Id IS NULL	




	