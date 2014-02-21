UPDATE booking_hotel_facility_types SET flag = 1 WHERE lower(name) like '%wifi%'
UPDATE booking_hotel_facility_types SET flag = 4 WHERE name = 'Children''s playground' OR name = 'Babysitting/child services' OR name = 'Kids'' club' 
UPDATE booking_hotel_facility_types SET flag = 8 WHERE lower(name) like '%parking%';
UPDATE booking_hotel_facility_types SET flag = 16 WHERE name = 'Fitness centre' 
UPDATE booking_hotel_facility_types SET flag = 64 WHERE name = 'Non-smoking rooms' OR name = 'Non-smoking throughout' OR name = 'Designated smoking area'
UPDATE booking_hotel_facility_types SET flag =128 WHERE name = 'Pets allowed'
UPDATE booking_hotel_facility_types SET flag = 256 WHERE lower(name) like '%pool%' 
UPDATE booking_hotel_facility_types SET flag = 512 WHERE lower(name) like '%restaurant%';
UPDATE booking_hotel_facility_types SET flag =1024 WHERE name like 'Spa and wellness centre';
select * from booking_hotel_facility_types where flag is null order by id  asc