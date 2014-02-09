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
ALTER TABLE hotels ADD COLUMN splndia_user_rating double precision;


