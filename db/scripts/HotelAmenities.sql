/*
	First add the new column
*/
ALTER TABLE ean_hotel_attributes ADD hotel_amenities_id INTEGER NULL;

/*
	Set it to null if it already exists
*/
UPDATE ean_hotel_attributes SET hotel_amenities_id = NULL;

/*
	Populate "Wifi"
*/
UPDATE ean_hotel_attributes SET hotel_amenities_id = 1
WHERE
	Description ILIKE '%wifi%'
OR
	Description ILIKE '%wi-fi%'	
OR
	Description ILIKE '%wireless%';

/*	
	Populate "Central Location"
*/
--Note: No such amenity in EAN list - Could in theory compare to lat/long of city, but no guarantee that's reliable?

/*	
	Populate "Family Friendly"
*/
UPDATE ean_hotel_attributes SET hotel_amenities_id = 3
WHERE
(
	Description ILIKE '%fam%'
OR
	Description ILIKE '%child%'
OR
	Description ILIKE '%infant%'
)
AND id <> 922 --Mentions child but not "friendly"
AND id <> 731; --No beds for you

/*	
	Populate "Parking"
*/
UPDATE ean_hotel_attributes SET hotel_amenities_id = 4
WHERE
(
	Description ILIKE '%parking%'
)
AND id <> 821 --"Parking nearby (surcharge)"
AND id <> 575 --"Parking nearby"
AND id <> 736 --"Parking height restrictions apply"
AND id <> 898 --"Free parking nearby"
AND id <> 899 --"Offsite parking discounted rates available"
AND id <> 900 --"Offsite parking reservations required"
AND id <> 901 --"Free on-street parking"
AND id <> 902; --"Street parking (metered)"

/*	
	Populate "Gym"
	NOTE: Not included health clubs?
*/
UPDATE ean_hotel_attributes SET hotel_amenities_id = 5
WHERE
(
	Description ILIKE '%fit%'
)
AND id <> 604 --"Use of nearby fitness center (complimentary)"
AND id <> 670; --"Use of nearby fitness center (discount)"

/*	
	Populate "Boutique"
	NOTE: Assumes "Boutique" to mean on-site shop
*/
UPDATE ean_hotel_attributes SET hotel_amenities_id = 6
WHERE id = 490
OR id = 491;

/*	
	Populate "Non-smoking rooms"
*/
UPDATE ean_hotel_attributes SET hotel_amenities_id = 7
WHERE id = 648 
OR id = 803;

/*	
	Populate "Pet Friendly"
	NOTE: 492 seems the main, I'd expect all othes to depend on it. 2 more included for completeness
*/
UPDATE ean_hotel_attributes SET hotel_amenities_id = 8
WHERE id = 492
OR id = 779
OR id = 780;

/*	
	Populate "Pool"
*/
UPDATE ean_hotel_attributes SET hotel_amenities_id = 9
WHERE
(
	description ILIKE '%swim%'
	OR
	(description ILIKE '%pool%' AND description ILIKE '%private%')
);

/*	
	Populate "Restaurant"
*/
UPDATE ean_hotel_attributes SET hotel_amenities_id = 10
WHERE
(
	description ILIKE '%resta%'
);

/*	
	Populate "Spa"
*/
UPDATE ean_hotel_attributes SET hotel_amenities_id = 11
WHERE
(
	description ILIKE '%spa %'
);

/*
	Create a many-to-many table between hotels and hotel_amenities
*/
CREATE TABLE hotels_hotel_amenities
(
  hotel_id integer NOT NULL,
  hotel_amenity_id integer,
  CONSTRAINT hotels_hotel_amenities_pkey PRIMARY KEY (hotel_id, hotel_amenity_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE hotels_hotel_amenities
  OWNER TO u1uf61dvp27blk;

/*
	Insert into the many-to-many table based on the ean_hotel_id
	658,893 rows 
*/
DELETE FROM hotels_hotel_amenities;

INSERT INTO hotels_hotel_amenities(hotel_id, hotel_amenity_id)
SELECT DISTINCT
	H.id,
	HA.id
FROM
	hotels AS H
	INNER JOIN ean_hotels AS EH
	ON H.ean_hotel_id = EH.id
	INNER JOIN ean_hotel_attribute_links AS EHAL
	ON EHAL.ean_hotel_id = EH.id	
	INNER JOIN ean_hotel_attributes AS EHA
	ON EHA.attribute_id = EHAL.attribute_id
	INNER JOIN hotel_amenities AS HA
	ON HA.id = EHA.hotel_amenities_id;

/*
	Can update the bitflag on hotel table now
	Appx 143377 rows

	OPTIONAL: UPDATE hotels SET Amenities = 0
*/
UPDATE hotels AS H
SET amenities = T1.bitmask
FROM
(
	SELECT
		id,
		SUM(value) AS bitmask
	FROM
	(
		SELECT DISTINCT
			H.id,
			HA.value
		FROM
			hotels AS H
			INNER JOIN ean_hotels AS EH
			ON H.ean_hotel_id = EH.id
			INNER JOIN ean_hotel_attribute_links AS EHAL
			ON EHAL.ean_hotel_id = EH.id	
			INNER JOIN ean_hotel_attributes AS EHA
			ON EHA.attribute_id = EHAL.attribute_id
			INNER JOIN hotel_amenities AS HA
			ON HA.id = EHA.hotel_amenities_id
	) AS T
	GROUP BY
		id
)AS T1
WHERE
	T1.id = H.id;


