
update locations set etb_city_id = cities.etb_id
FROM (
select etb.id as  etb_id, l.id from etb_cities etb
join locations l on l.city = etb.city_name and l.region = etb.province_name) as cities
where locations.id= cities.id

update locations set etb_city_id = cities.etb_id
FROM (
select etb.id as  etb_id, l.id from etb_cities etb
join locations l on l.city = etb.city_name and left(l.region, length(etb.province_name)) = etb.province_name
and l.etb_city_id is null) as cities
where locations.id= cities.id 

update locations set etb_city_id = cities.etb_id
FROM (
select etb.id as  etb_id, l.id from etb_cities etb
join etb_countries c on c.id = etb.country_id
 join locations l on l.city = etb.city_name and l.country_code = lower(c.country_iso) and l.region is null) as cities
where locations.id= cities.id 

update locations set etb_city_id = cities.etb_id
FROM (
select etb.id as  etb_id, l.id from etb_cities etb
 join locations l on ST_DWithin(etb.geog, l.geog,10000) 
where l.etb_city_id is null and l.id is not null and etb.city_name= l.city) as cities
where locations.id= cities.id 


select * from etb_cities etb
left join locations l on l.etb_city_id = etb.id 
where l.etb_city_id is null

select * from etb_cities etb
join etb_countries c on c.id = etb.country_id
left join locations l on l.city = etb.city_name and l.country_code = lower(c.country_iso) 
where l.etb_city_id is null and l.id is not null and etb.city_name = 'Springfield'

select etb.city_name, etb.province_name, l.city, l.region, st_distance(etb.geog, l.geog)  from etb_cities etb
 join locations l on ST_DWithin(etb.geog, l.geog,10000) 
where l.etb_city_id is null and l.id is not null and etb.city_name= l.city


select * from locations where city = 'Springfield'
select * from etb_cities where city_name = 'Springfield'

-1.16667;44.65
-1.149931;44.654776