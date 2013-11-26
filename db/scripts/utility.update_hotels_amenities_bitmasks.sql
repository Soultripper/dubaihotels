-- Function: utility.update_hotels_amenities_bitmasks()

-- DROP FUNCTION utility.update_hotels_amenities_bitmasks();

CREATE OR REPLACE FUNCTION utility.update_hotels_amenities_bitmasks()
  RETURNS void AS
$BODY$UPDATE hotels AS H
SET amenities = T1.bitmask
FROM
(
	SELECT
		id,
		SUM(flag) AS bitmask
	FROM
	(
		SELECT DISTINCT
			H.id,
			HA.flag
		FROM
			hotels AS H
			INNER JOIN hotels_hotel_amenities AS HHA
			ON H.id = HHA.hotel_id
			INNER JOIN hotel_amenities AS HA
			ON HA.Id = HHA.hotel_amenity_id
	) AS T
	GROUP BY
		id
)AS T1
WHERE
	T1.id = H.id;	$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION utility.update_hotels_amenities_bitmasks()
  OWNER TO u1uf61dvp27blk;
