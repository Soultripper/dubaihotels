--Add Geography
ALTER TABLE agoda_hotels ADD COLUMN geog geography(Point,4326);

--Update Geography
UPDATE agoda_hotels SET geog = CAST(ST_SetSRID(ST_Point(longitude, latitude),4326) As geography)
WHERE (longitude BETWEEN -180 AND 180)
AND (Latitude BETWEEN -90 AND 90);
--Except for hotel 445969 which has an invalid latitude :s

--Index Geography
CREATE INDEX agoda_hotels_geog_idx
  ON agoda_hotels
  USING gist(geog);

--86,090 to match

--Initial update of 22,386 
UPDATE Public.Hotels AS H
SET Agoda_Hotel_Id = AH.Id
FROM
	Public.Agoda_Hotels AS AH
WHERE
	LOWER(H.country_code) = LOWER(AH.countryISOCode)
	AND LOWER(H.postal_code) = LOWER(AH.zipcode)
	AND LOWER(H.Name) = LOWER(AH.Hotel_Name)

--Second pass of 10,247
UPDATE Public.Hotels AS H
SET Agoda_Hotel_Id = AH.Id
FROM
	Public.Agoda_Hotels AS AH
WHERE
	LOWER(H.Name) = LOWER(AH.Hotel_Name)
	AND ST_DWithin(AH.geog, H.Geog, 500)
	AND H.Agoda_Hotel_Id IS NULL	

--Third pass of 674
UPDATE Public.Hotels AS H
SET Agoda_Hotel_Id = AH.Id
FROM
	Public.Agoda_Hotels AS AH
WHERE
	LOWER(H.Name) = LOWER(AH.Hotel_Name)
	AND ST_DWithin(AH.geog, H.Geog, 1000)
	AND H.Agoda_Hotel_Id IS NULL

--Fourth pass of 986
UPDATE Public.Hotels AS H
SET Agoda_Hotel_Id = AH.Id
FROM
	Public.Agoda_Hotels AS AH
WHERE
	LOWER(H.Name) = LOWER(AH.Hotel_Name)
	AND ST_DWithin(AH.geog, H.Geog, 10000)
	AND H.Agoda_Hotel_Id IS NULL	




	