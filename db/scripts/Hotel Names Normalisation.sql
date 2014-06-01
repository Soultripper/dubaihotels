
truncate table hotel_names;

insert into hotel_names
select id, name, REPLACE(lower(name), lower(city), '') , REPLACE(lower(name), lower(city), '') from hotels;

update hotel_names 
set lower_name = lower(name), normal_name = lower(name)
where COALESCE(lower_name,'') = '';

UPDATE hotel_names 
SET normal_name = REGEXP_REPLACE(lower_name, '\y(the|hotel|inn|by|apartments|apartment|B&B|and|hostel|villa|de|le|motel|guest|bed|breakfast|suites|spa|")\y|\W', '', 'ig');

update hotel_names 
set normal_name = lower(name)
where COALESCE(normal_name,'') = '';


UPDATE hotels
SET normal_name = t1.normal_name
FROM
(
select id, normal_name from hotel_names
) AS t1
WHERE hotels.id = t1.id