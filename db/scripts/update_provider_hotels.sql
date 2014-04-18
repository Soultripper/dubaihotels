-- booking
UPDATE provider_hotels p
SET hotel_id = T1.id
FROM
	(SELECT id, booking_hotel_id
	FROM hotels 
	WHERE booking_hotel_id IS NOT NULL) AS T1
WHERE p.provider_id = 'booking' AND p.provider_hotel_id = T1.booking_hotel_id;

-- expedia
UPDATE provider_hotels p
SET hotel_id = T1.id
FROM
	(SELECT id, ean_hotel_id
	FROM hotels 
	WHERE ean_hotel_id IS NOT NULL) AS T1
WHERE p.provider_id = 'expedia' AND p.provider_hotel_id = T1.ean_hotel_id;

-- agoda
UPDATE provider_hotels p
SET hotel_id = T1.id
FROM
	(SELECT id, agoda_hotel_id
	FROM hotels 
	WHERE agoda_hotel_id IS NOT NULL) AS T1
WHERE p.provider_id = 'agoda' AND p.provider_hotel_id = T1.agoda_hotel_id;

--laterooms
UPDATE provider_hotels p
SET hotel_id = T1.id
FROM
	(SELECT id, laterooms_hotel_id
	FROM hotels 
	WHERE laterooms_hotel_id IS NOT NULL) AS T1
WHERE p.provider_id = 'laterooms' AND p.provider_hotel_id = T1.laterooms_hotel_id;

-- splendia
UPDATE provider_hotels p
SET hotel_id = T1.id
FROM
	(SELECT id, splendia_hotel_id
	FROM hotels 
	WHERE splendia_hotel_id IS NOT NULL) AS T1
WHERE p.provider_id = 'splendia' AND p.provider_hotel_id = T1.splendia_hotel_id;

-- easy_to_book
UPDATE provider_hotels p
SET hotel_id = T1.id
FROM
	(SELECT id, etb_hotel_id
	FROM hotels 
	WHERE etb_hotel_id IS NOT NULL) AS T1
WHERE p.provider_id = 'easy_to_book' AND p.provider_hotel_id = T1.etb_hotel_id;

-- venere
UPDATE provider_hotels p
SET hotel_id = T1.id
FROM
	(SELECT id, venere_hotel_id
	FROM hotels 
	WHERE venere_hotel_id IS NOT NULL) AS T1
WHERE p.provider_id = 'venere' AND p.provider_hotel_id = T1.venere_hotel_id;


--SELECT COUNT(*) FROM provider_hotels WHERE hotel_id IS NULL
--SELECT * FROM provider_hotels WHERE hotel_id IS NULL LIMIT 100

ALTER TABLE provider_hotels ADD COLUMN name_normal character varying(255);


 UPDATE provider_hotels SET name_normal = LOWER(name)
UPDATE provider_hotels SET name_normal = REGEXP_REPLACE(name_normal, '\([^)]*\)', '') WHERE name_normal ~ '\([^)]*\)' 
UPDATE provider_hotels SET name_normal = REGEXP_REPLACE(name_normal, '(\s+hotel$)' , '') WHERE name_normal ~ '\s+hotel$' 
