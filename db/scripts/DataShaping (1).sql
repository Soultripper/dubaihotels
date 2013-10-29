-- Columns to allow a single trigram search across multiple columns
ALTER TABLE hotels ADD COLUMN "nameaddress" character varying(1024);
ALTER TABLE ean_hotels ADD COLUMN "nameaddress" character varying(1024);

--5 mins
UPDATE hotels SET nameaddress =
	COALESCE(Name, '') || '  ' ||
	COALESCE(Address, '') || '  ' ||
	COALESCE(City, '') || '  ' ||
	COALESCE(State_Province, '') || '  ' ||
	COALESCE(Postal_Code, '') || '  ' ||
	COALESCE(Country_Code, '');
			
--3 mins
UPDATE ean_hotels SET nameaddress =
	COALESCE(Name, '') || '  ' ||
	COALESCE(Address1, '') || '  ' ||
	COALESCE(Address2, '') || '  ' ||
	COALESCE(City, '') || '  ' ||
	COALESCE(State_Province, '') || '  ' ||
	COALESCE(Postal_Code, '') || '  ' ||
	COALESCE(Country, '');		

--Indexing
CREATE INDEX hotels_nameaddress_trgm_idx ON hotels USING gist (nameaddress gist_trgm_ops);
CREATE INDEX ean_hotels_nameaddress_trgm_idx ON ean_hotels USING gist (nameaddress gist_trgm_ops);

--Create a new table to hold the Hotel & EAN Hotel Ids where the EAN hotel is within 5k of the Hotel
CREATE TABLE hotels_ean_hotels_within_five_kilometers
(
  hotel_id integer NOT NULL,
  ean_hotel_id integer NOT NULL,
  CONSTRAINT "PK" PRIMARY KEY (hotel_id, ean_hotel_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE hotels_ean_hotels_within_five_kilometers
  OWNER TO postgres;

--Populate the table just created
--This population query takes about 12 minutes on an slow laptop
INSERT INTO hotels_ean_hotels_within_five_kilometers
SELECT
	H.Id,
	E.Id
FROM
	hotels AS H
	JOIN EAN_Hotels AS E
	ON ST_DWithin(H.geog, E.geog, 5000)

--Function to speed things up, as Postgres LATERAL keyword needs a lot of work
CREATE OR REPLACE FUNCTION get_best_ean_hotel(_hotel_id INTEGER)
RETURNS SETOF ean_hotels AS
$BODY$
BEGIN
		RETURN QUERY
		SELECT 
			E.*		
		FROM
			EAN_Hotels AS E
			INNER JOIN hotels_ean_hotels_within_five_kilometers AS EH
			ON E.Id = EH.ean_hotel_id
			INNER JOIN hotels AS HInner 
			ON HInner.Id = EH.hotel_id
		WHERE
			Hinner.Id = _hotel_id
		ORDER BY
			ST_Distance(HInner.geog, e.geog) * (HInner.nameaddress <-> e.nameaddress)  ASC
		LIMIT 1;
END;
$BODY$
LANGUAGE plpgsql;
  
--Example query that shows first 1000 hotels and their match
--Use this to establish where to draw the line. Powers control how the falloff works with distance.
SELECT
	H.Id,
	H.nameaddress,
	E.Id,
	E.nameaddress,
	ST_Distance(H.geog, E.geog) AS Distance,
	similarity(H.nameaddress, E.nameaddress) AS Similarity,
	ST_Distance(H.geog, E.geog) * POWER((1 - similarity(H.nameaddress, E.nameaddress)), 10) AS SimValue,
	H.ean_hotel_id	
FROM
	hotels AS H
	JOIN LATERAL 
	(SELECT * FROM get_best_ean_hotel(H.Id)) AS E
	ON TRUE
WHERE
	H.Id < 1000
AND
	ST_Distance(H.geog, E.geog) * POWER((1 - similarity(H.nameaddress, E.nameaddress)), 10)  <= 0.1
AND
	similarity(H.nameaddress, E.nameaddress) > 0.62
ORDER BY
	ST_Distance(H.geog, E.geog) * POWER((1 - similarity(H.nameaddress, E.nameaddress)), 10) DESC


-- Create a staging table
CREATE TABLE hotels_ean_hotels_matches_weighted_staging
(
  hotel_id integer,
  ean_hotel_id integer,
  weighting double precision
)
WITH (
  OIDS=FALSE
);
ALTER TABLE hotels_ean_hotels_matches_weighted_staging
  OWNER TO postgres;


-- Insert into staging table in pieces (Change the Id filter)
INSERT INTO hotels_ean_hotels_matches_weighted_staging
(
  hotel_id,
  ean_hotel_id,
  weighting
)
SELECT
	H.id,
	E.id, 
	ST_Distance(H.geog, E.geog) * POWER((1 - similarity(H.nameaddress, E.nameaddress)), 10)
FROM
	hotels AS H
	JOIN LATERAL 
	(SELECT * FROM get_best_ean_hotel(H.Id)) AS E
	ON TRUE
WHERE
	ST_Distance(H.geog, E.geog) * POWER((1 - similarity(H.nameaddress, E.nameaddress)), 10)  <= 0.1
AND
	similarity(H.nameaddress, E.nameaddress) > 0.62
AND
	H.Id > 300000

--Remove any duplicates (2715 in initial run)
DELETE
FROM
	hotels_ean_hotels_matches_weighted_staging AS W
	USING
	(
		SELECT * 
		FROM
		(
			SELECT
				ean_hotel_id, 
				Hotel_id,
				weighting,
				ROW_NUMBER() OVER(PARTITION BY ean_hotel_id ORDER BY weighting) AS Eliminator
			FROM
				hotels_ean_hotels_matches_weighted_staging
			WHERE ean_hotel_id IN
			(
				SELECT
					ean_hotel_id
				FROM
					hotels_ean_hotels_matches_weighted_staging
				GROUP BY
					ean_hotel_id
				HAVING COUNT(*) > 1
			)
		) AS T
		WHERE T.Eliminator = 2
	)AS D
	WHERE D.hotel_id = W.hotel_id
	AND D.ean_hotel_id = W.ean_hotel_id



