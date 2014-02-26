-- select * from agoda_hotels limit 100 -- Agoda is out of 10
-- select * from booking_hotels limit 100 -- Booking is out of 10
-- select * from late_rooms_hotels limit 100  -- laterooms is out of 6
-- select * from etb_hotels limit 100  -- EasyToBook is out of 5
-- select * from splendia_hotels limit 100 -- Splendia is out of 100%
-- select * from ean_hotels limit 100 -- EAN hotels have no user score
-- select * from hotels limit 100

-- Booking
-- EAN
-- Agoda
-- EasyToBook
--Splendia
-- Laterooms

ALTER TABLE hotels ADD COLUMN agoda_user_rating double precision;
ALTER TABLE hotels ADD COLUMN laterooms_user_rating double precision;
ALTER TABLE hotels ADD COLUMN etb_user_rating double precision;
ALTER TABLE hotels ADD COLUMN splendia_user_rating double precision;

UPDATE hotels SET user_rating = ( COALESCE(booking_user_rating,0) + (COALESCE(agoda_user_rating,0) * 10) + (COALESCE(laterooms_user_rating,0) * 16.6) + (COALESCE(etb_user_rating,0) * 20) + COALESCE(splendia_user_rating,0)) / matches
WHERE matches > 0

select * from hotels 
where matches > 4
order by user_rating desc  limit 1000

SELECT( (COALESCE(booking_user_rating,0) * 10) + (COALESCE(agoda_user_rating,0) * 10) + (COALESCE(laterooms_user_rating,0) * 16.6) + (COALESCE(etb_user_rating,0) * 20) + COALESCE(splendia_user_rating,0)) / 
	(CASE WHEN booking_user_rating > 0 THEN 1 ELSE 0 END + 
	CASE WHEN agoda_user_rating > 0 THEN 1 ELSE 0 END  + 
	CASE WHEN laterooms_user_rating > 0 THEN 1 ELSE 0 END + 
	CASE WHEN etb_user_rating > 0 THEN 1 ELSE 0 END + 
	CASE WHEN splendia_user_rating > 0 THEN 1 ELSE 0 END)
FROM hotels
WHERE 
	(CASE WHEN booking_user_rating > 0 THEN 1 ELSE 0 END + 
	CASE WHEN agoda_user_rating > 0 THEN 1 ELSE 0 END  + 
	CASE WHEN laterooms_user_rating > 0 THEN 1 ELSE 0 END + 
	CASE WHEN etb_user_rating > 0 THEN 1 ELSE 0 END + 
	CASE WHEN splendia_user_rating > 0 THEN 1 ELSE 0 END) > 0 
LIMIT 200

WHERE id = 20514

select * from hotels where id = 20514