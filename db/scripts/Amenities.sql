
-- Booking.com
UPDATE hotels
SET amenities = COALESCE(amenities,0) | COALESCE(T2.bitmask,0)
FROM (
	SELECT T1.booking_hotel_id, SUM(T1.flag) AS bitmask
	FROM
	(
		SELECT DISTINCT 
			booking_hotel_id AS booking_hotel_id, 
			flag  AS flag
		FROM booking_hotel_facility_types spa
		JOIN booking_hotel_amenities sa on sa.booking_facility_type_id = spa.id
		WHERE spa.flag IS NOT NULL
		GROUP BY booking_hotel_id, flag
		ORDER BY 1
	) AS T1
	GROUP BY T1.booking_hotel_id
) AS T2
WHERE hotels.booking_hotel_id = T2.booking_hotel_id;

-- EXPEDIA
UPDATE hotels AS H
SET amenities = COALESCE(amenities,0) | COALESCE(T1.bitmask,0)
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
			INNER JOIN ean_hotels AS EH ON H.ean_hotel_id = EH.id
			INNER JOIN ean_hotel_attribute_links AS EHAL ON EHAL.ean_hotel_id = EH.id	
			INNER JOIN ean_hotel_attributes AS EHA ON EHA.attribute_id = EHAL.attribute_id
			INNER JOIN hotel_amenities AS HA ON HA.id = EHA.hotel_amenities_id
	) AS T
	GROUP BY
		id
)AS T1
WHERE
	T1.id = H.id;

-- AGODA
UPDATE hotels
SET amenities = COALESCE(amenities,0) | COALESCE(T2.bitmask,0)
FROM (
	SELECT T1.agoda_hotel_id, SUM(T1.flag) AS bitmask
	FROM
	(
		SELECT DISTINCT 
			agoda_hotel_id AS agoda_hotel_id, 
			flag  AS flag
		FROM agoda_hotel_facilities spa
		JOIN agoda_amenities sa on sa.description = spa.name
		WHERE sa.flag IS NOT NULL
		GROUP BY agoda_hotel_id, flag
		ORDER BY 1
	) AS T1
	GROUP BY T1.agoda_hotel_id
) AS T2
WHERE hotels.agoda_hotel_id = T2.agoda_hotel_id;

--SPLENDIA
UPDATE hotels
SET amenities = COALESCE(amenities,0) | COALESCE(T2.bitmask,0)
FROM (
	SELECT T1.splendia_hotel_id, SUM(T1.flag) AS bitmask
	FROM
	(
		SELECT DISTINCT 
			splendia_hotel_id AS splendia_hotel_id, 
			flag  AS flag
		FROM splendia_hotel_amenities spa
		JOIN splendia_amenities sa on sa.description = spa.amenity
		WHERE sa.flag IS NOT NULL
		GROUP BY splendia_hotel_id, flag
		ORDER BY 1
	) AS T1
	GROUP BY T1.splendia_hotel_id
) AS T2
WHERE hotels.splendia_hotel_id = T2.splendia_hotel_id;

-- EASY_TO_BOOK
UPDATE hotels 
SET amenities = COALESCE(amenities,0) | COALESCE(T2.bitmask,0)
FROM (
	SELECT id, flag AS bitmask
	FROM etb_hotel_facilities 
	WHERE flag IS NOT NULL
	) AS T1
WHERE hotels.etb_hotel_id = T1.id ;

