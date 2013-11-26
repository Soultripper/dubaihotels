--WiFi (1430 rows on prod, 15s)
INSERT INTO hotels_hotel_amenities
(hotel_id, hotel_amenity_id)
SELECT DISTINCT 
	H.Id,
	1
FROM 
	etb_hotel_facilities AS ETBHF
	INNER JOIN etb_hotels AS ETBH 
	ON ETBHF.id = ETBH.id
	INNER JOIN hotels AS H
	ON H.etb_hotel_id = ETBH.id
WHERE 
(
	Internet ILIKE '%WIFI%'
	OR Internet ILIKE '%WI-FI%'
)
AND NOT EXISTS
(
	SELECT * FROM hotels_hotel_amenities WHERE hotel_id = H.id AND hotel_amenity_id = 1
);

--Family Friendly (514 rows, 5s)
INSERT INTO hotels_hotel_amenities
(hotel_id, hotel_amenity_id)
SELECT DISTINCT 
	H.Id,
	4
FROM 
	etb_hotel_facilities AS ETBHF
	INNER JOIN etb_hotels AS ETBH 
	ON ETBHF.id = ETBH.id
	INNER JOIN hotels AS H
	ON H.etb_hotel_id = ETBH.id
WHERE 
(	
	services ILIKE '%child care%'
	OR services ILIKE '%creche%'
)
AND NOT EXISTS
(
	SELECT * FROM hotels_hotel_amenities WHERE hotel_id = H.id AND hotel_amenity_id = 4
);

--Parking (64k rows, 14s)
INSERT INTO hotels_hotel_amenities
(hotel_id, hotel_amenity_id)
SELECT DISTINCT 
	H.Id,
	8
FROM 
	etb_hotel_facilities AS ETBHF
	INNER JOIN etb_hotels AS ETBH 
	ON ETBHF.id = ETBH.id
	INNER JOIN hotels AS H
	ON H.etb_hotel_id = ETBH.id
WHERE parking NOT ILIKE 'Parking Nearby'
AND NOT parking ILIKE 'Parking Nearby, Parking Nearby (surcharge)'
AND NOT EXISTS
(
	SELECT * FROM hotels_hotel_amenities WHERE hotel_id = H.id AND hotel_amenity_id = 8
);

--Gym (39k rows, 4s)
INSERT INTO hotels_hotel_amenities
(hotel_id, hotel_amenity_id)
SELECT DISTINCT 
	H.Id,
	16
FROM 
	etb_hotel_facilities AS ETBHF
	INNER JOIN etb_hotels AS ETBH 
	ON ETBHF.id = ETBH.id
	INNER JOIN hotels AS H
	ON H.etb_hotel_id = ETBH.id
WHERE 
(
	activities ILIKE '%fit%'
	OR activities ILIKE '%gym%'
)
AND NOT EXISTS
(
	SELECT * FROM hotels_hotel_amenities WHERE hotel_id = H.id AND hotel_amenity_id = 16
);

--Non-Smoking rooms (43k rows, 3s)
INSERT INTO hotels_hotel_amenities
(hotel_id, hotel_amenity_id)
SELECT DISTINCT 
	H.Id,
	64
FROM 
	etb_hotel_facilities AS ETBHF
	INNER JOIN etb_hotels AS ETBH 
	ON ETBHF.id = ETBH.id
	INNER JOIN hotels AS H
	ON H.etb_hotel_id = ETBH.id
WHERE 
(
	general_facilities ILIKE '%non-smoking%'
	OR general_facilities ILIKE '%smoking not%'
)
AND NOT EXISTS
(
	SELECT * FROM hotels_hotel_amenities WHERE hotel_id = H.id AND hotel_amenity_id = 64
);

--Pet Friendly (13k rows, 2s)
INSERT INTO hotels_hotel_amenities
(hotel_id, hotel_amenity_id)
SELECT DISTINCT 
	H.Id,
	128
FROM 
	etb_hotel_facilities AS ETBHF
	INNER JOIN etb_hotels AS ETBH 
	ON ETBHF.id = ETBH.id
	INNER JOIN hotels AS H
	ON H.etb_hotel_id = ETBH.id
WHERE 
(
	general_facilities ILIKE '%pets allowed%'
)AND NOT EXISTS
(
	SELECT * FROM hotels_hotel_amenities WHERE hotel_id = H.id AND hotel_amenity_id = 128
);

--Pool (6 rows, 0.6s)
INSERT INTO hotels_hotel_amenities
(hotel_id, hotel_amenity_id)
SELECT DISTINCT 
	H.Id,
	256
FROM 
	etb_hotel_facilities AS ETBHF
	INNER JOIN etb_hotels AS ETBH 
	ON ETBHF.id = ETBH.id
	INNER JOIN hotels AS H
	ON H.etb_hotel_id = ETBH.id
WHERE 
(
	activities ILIKE '%water%'
)AND NOT EXISTS
(
	SELECT * FROM hotels_hotel_amenities WHERE hotel_id = H.id AND hotel_amenity_id = 256
);

--Restaurant (49k rows, 2s)
INSERT INTO hotels_hotel_amenities
(hotel_id, hotel_amenity_id)
SELECT DISTINCT 
	H.Id,
	512
FROM
	etb_hotel_facilities AS ETBHF
	INNER JOIN etb_hotels AS ETBH 
	ON ETBHF.id = ETBH.id
	INNER JOIN hotels AS H
	ON H.etb_hotel_id = ETBH.id
WHERE
	extra_common_areas ILIKE '%Restaurant%'
AND NOT EXISTS
(
	SELECT * FROM hotels_hotel_amenities WHERE hotel_id = H.id AND hotel_amenity_id = 512
);

--Spa (37k rows, 2s)
INSERT INTO hotels_hotel_amenities
(hotel_id, hotel_amenity_id)
SELECT DISTINCT 
	H.Id,
	1024
FROM 
	etb_hotel_facilities AS ETBHF
	INNER JOIN etb_hotels AS ETBH 
	ON ETBHF.id = ETBH.id
	INNER JOIN hotels AS H
	ON H.etb_hotel_id = ETBH.id
WHERE 
(
	wellness_facilities ILIKE '%spa%'
	OR LENGTH(wellness_facilities) > 12
)
AND NOT EXISTS
(
	SELECT * FROM hotels_hotel_amenities WHERE hotel_id = H.id AND hotel_amenity_id = 1024
);



SELECT utility.update_hotels_amenities_bitmasks();


/*
"wifi";1
"central-location";2
"family-friendly";4
"parking";8
"gym";16
"boutique";32
"non-smoking-rooms";64
"pet-friendly";128
"pool";256
"restaurant";512
"spa";1024
*/