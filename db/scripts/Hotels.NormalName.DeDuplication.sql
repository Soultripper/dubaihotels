/*
	Change required distance & similarity below
	At 100% (1.00) and 100 meters, was 1515 seconds (25 minutes). 7904 duplicates, appx 3950 deletes. 1 bad match observed.
	At 90% (0.90) and 100 meters was 1916 seconds (32 minutes), 2892 duplicates, 1266 deletes. No bad matches observed.
	At 80% (0.80) and 100 meters was 3037 seconds (50 minutes), 5636 duplicates, 1812 deletes. Two bad matches spotted, Apartment numbers differed.
	Notes: 
		This version doesn't merge rooms/images/other, it just retains the victor.
		This version doesn't delete unmatched rooms/images/provider hotels/other.
*/
/*
	Temp tables, as there's just too much work otherwise (Too slow)
*/
CREATE TABLE IF NOT EXISTS temp_normal_matching
(
	lhs_id INT NOT NULL,
	rhs_id INT NOT NULL,
	lhs_ranking INT NULL, -- Populate after initial load, memory pressure forced order
	rhs_ranking INT NULL -- Ditto
);
TRUNCATE TABLE temp_normal_matching; -- In case it already existed

INSERT INTO temp_normal_matching
(lhs_id, rhs_id)
SELECT
	lhs.id,
	rhs.id
FROM
	hotels AS lhs
	INNER JOIN hotels AS rhs
	ON ST_DWithin(lhs.geog, rhs.geog, 100)
	AND SIMILARITY(lhs.normal_name, rhs.normal_name) >= 1
	AND lhs.id != rhs.id;

CREATE INDEX lhs_id_idx ON temp_normal_matching USING btree(lhs_id);
CREATE INDEX rhs_id_idx ON temp_normal_matching USING btree(rhs_id);

/*
	Update the ranking, sadly can't use CTE in pgSQL (Known bug)
*/		
UPDATE temp_normal_matching AS T
SET
	lhs_ranking = lhs.ranking
FROM
	(
		SELECT
			hotel_id,
			SUM(width * height) AS ranking
		FROM
			hotel_images as HI		
		GROUP BY
			hotel_id
	)AS lhs
WHERE
	lhs.hotel_id = T.lhs_id;

UPDATE temp_normal_matching AS T
SET
	rhs_ranking = rhs.ranking
FROM
	(
		SELECT
			hotel_id,
			SUM(width * height) AS ranking
		FROM
			hotel_images as HI	
		GROUP BY
			hotel_id
	)AS rhs
WHERE
	rhs.hotel_id = T.rhs_id;		

UPDATE temp_normal_matching
SET 
	lhs_ranking = COALESCE(lhs_ranking, 0),
	rhs_ranking = COALESCE(rhs_ranking, 0);

--Kludge/Tie-Breaker
UPDATE temp_normal_matching
SET
	lhs_ranking = lhs_id,
	rhs_ranking = rhs_id
WHERE
	lhs_ranking = 0
AND
	rhs_ranking = 0;

/*
	Use ranking to establish new temp table for victors and victims
*/
CREATE TABLE IF NOT EXISTS temp_normal_matching_victors_victims
(
	victor_id INT NOT NULL,
	victim_id INT NOT NULL
);
TRUNCATE TABLE temp_normal_matching_victors_victims; -- In case it already existed

INSERT INTO temp_normal_matching_victors_victims
(victor_id, victim_id)
SELECT DISTINCT
	CASE WHEN lhs_ranking >= rhs_ranking THEN lhs_id ELSE rhs_id END AS Victor,
	CASE WHEN lhs_ranking < rhs_ranking THEN lhs_id ELSE rhs_id END AS Victim		
FROM temp_normal_matching AS T;

CREATE INDEX victor_id_idx ON temp_normal_matching_victors_victims USING btree(victor_id);
CREATE INDEX victim_id_idx ON temp_normal_matching_victors_victims USING btree(victim_id);

/*
	Recursive CTE to get all the victor of victim roots into a temp table
*/
CREATE TABLE IF NOT EXISTS temp_normal_matching_victors_victims_roots
(
	victor_id INT NOT NULL,
	victim_id INT NOT NULL
);
TRUNCATE TABLE temp_normal_matching_victors_victims_roots; -- In case it already existed
WITH RECURSIVE CTE(root_victor_id, current_victor_id, current_victim_id, depth)
AS
(
	SELECT 
		victor_id, victor_id, victim_id, 1
	FROM 
		temp_normal_matching_victors_victims
	WHERE 
		victor_id NOT IN (SELECT victim_id FROM temp_normal_matching_victors_victims)
	UNION ALL
	SELECT 
		CTE.root_victor_id, T.victor_id, T.victim_id, CTE.depth + 1
	FROM 
		temp_normal_matching_victors_victims AS T
		INNER JOIN CTE 
		ON CTE.current_victim_id = T.victor_id
)
INSERT INTO temp_normal_matching_victors_victims_roots
(victor_id, victim_id)
SELECT DISTINCT
	root_victor_id,
	current_victim_id
FROM
	CTE; 

CREATE INDEX victor_root_id_idx ON temp_normal_matching_victors_victims_roots USING btree(victor_id);
CREATE INDEX victim_root_id_idx ON temp_normal_matching_victors_victims_roots USING btree(victim_id);

/*
	Now we have a clean list of victors and victims, map victim matches to empty victor matches
*/
UPDATE hotels AS victors
SET
	ean_hotel_id = COALESCE(victors.ean_hotel_id,victims.ean_hotel_id),
	booking_hotel_id = COALESCE(victors.booking_hotel_id,victims.booking_hotel_id),
	agoda_hotel_id = COALESCE(victors.agoda_hotel_id,victims.agoda_hotel_id),
	etb_hotel_id = COALESCE(victors.etb_hotel_id,victims.etb_hotel_id),
	splendia_hotel_id = COALESCE(victors.splendia_hotel_id,victims.splendia_hotel_id),
	laterooms_hotel_id = COALESCE(victors.laterooms_hotel_id,victims.laterooms_hotel_id),
	venere_hotel_id = COALESCE(victors.venere_hotel_id,victims.venere_hotel_id)
FROM 
	temp_normal_matching_victors_victims_roots AS T,
	hotels as victims
WHERE
	victors.id = T.victor_id
AND
	victims.id = T.victim_id;

/*
	Lastly delete victims
*/
DELETE FROM hotels
WHERE id IN (SELECT victim_id FROM temp_normal_matching_victors_victims_roots);

/*
	Tidy up
*/
DROP TABLE temp_normal_matching_victors_victims_roots;
DROP TABLE temp_normal_matching_victors_victims;
DROP TABLE temp_normal_matching;