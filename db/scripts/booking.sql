UPDATE booking_hotel_facility_types SET flag = 1 WHERE lower(name) like '%wifi%'
UPDATE booking_hotel_facility_types SET flag = 4 WHERE name = 'Children''s playground' OR name = 'Babysitting/child services' OR name = 'Kids'' club' 
UPDATE booking_hotel_facility_types SET flag = 8 WHERE lower(name) like '%parking%';
UPDATE booking_hotel_facility_types SET flag = 16 WHERE name = 'Fitness centre' 
UPDATE booking_hotel_facility_types SET flag = 64 WHERE name = 'Non-smoking rooms' OR name = 'Non-smoking throughout' OR name = 'Designated smoking area'
UPDATE booking_hotel_facility_types SET flag =128 WHERE name = 'Pets allowed'
UPDATE booking_hotel_facility_types SET flag = 256 WHERE lower(name) like '%pool%' 
UPDATE booking_hotel_facility_types SET flag = 512 WHERE lower(name) like '%restaurant%';
UPDATE booking_hotel_facility_types SET flag =1024 WHERE name like 'Spa and wellness centre';
select * from booking_hotel_facility_types where flag is not  null order by id  asc



UPDATE hotels
SET amenities = T2.bitmask
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
WHERE hotels.booking_hotel_id = T2.booking_hotel_id AND hotels.amenities IS NULL

