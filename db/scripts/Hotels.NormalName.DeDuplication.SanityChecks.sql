/*
	Sanity checking, do this before the final updates/deletes to the hotels table
*/	
SELECT 
	victors.name,
	victors.address,
	victims.name,
	victims.address,
	
	EHVictor.name,
	EHVictor.address1,
	EHVictim.name,
	EHVictim.address1,

	victors.ean_hotel_id,
	victims.ean_hotel_id
FROM 
	temp_normal_matching_victors_victims_roots AS T
	INNER JOIN hotels AS victors
	ON victors.id = T.victor_id
	INNER JOIN hotels as victims
	ON victims.id = T.victim_id
	INNER JOIN ean_hotels AS EHVictor
	ON EHVictor.id = victors.ean_hotel_id
	INNER JOIN ean_hotels AS EHVictim
	ON EHVictim.id = victims.ean_hotel_id	
WHERE
	EHVictor.id <> EHVictim.id;

SELECT 
	victors.name,
	victors.address,
	victims.name,
	victims.address,
	
	EHVictor.name,
	EHVictor.address,
	EHVictim.name,
	EHVictim.address,

	victors.etb_hotel_id,
	victims.etb_hotel_id
FROM 
	temp_normal_matching_victors_victims_roots AS T
	INNER JOIN hotels AS victors
	ON victors.id = T.victor_id
	INNER JOIN hotels as victims
	ON victims.id = T.victim_id
	INNER JOIN etb_hotels AS EHVictor
	ON EHVictor.id = victors.etb_hotel_id
	INNER JOIN etb_hotels AS EHVictim
	ON EHVictim.id = victims.etb_hotel_id	
WHERE
	EHVictor.id <> EHVictim.id;