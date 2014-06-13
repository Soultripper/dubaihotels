ALTER TABLE booking_hotels SET SCHEMA providers;
ALTER TABLE booking_hotel_images SET SCHEMA providers;
ALTER TABLE booking_hotel_descriptions SET SCHEMA providers;
ALTER TABLE booking_amenities SET SCHEMA providers;
ALTER TABLE booking_hotel_amenities SET SCHEMA providers;
ALTER TABLE booking_cities SET SCHEMA providers;
ALTER TABLE booking_countries SET SCHEMA providers;
ALTER TABLE booking_region_hotel_lookups SET SCHEMA providers;
ALTER TABLE booking_region_hotels SET SCHEMA providers;
ALTER TABLE booking_regions SET SCHEMA providers;

ALTER TABLE agoda_hotels SET SCHEMA providers;
ALTER TABLE agoda_hotel_images SET SCHEMA providers;
ALTER TABLE agoda_amenities SET SCHEMA providers;
ALTER TABLE agoda_hotel_amenities SET SCHEMA providers;
ALTER TABLE agoda_cities SET SCHEMA providers;
ALTER TABLE agoda_countries SET SCHEMA providers;
ALTER TABLE agoda_neighbourhoods SET SCHEMA providers;
ALTER TABLE agoda_regions SET SCHEMA providers;

ALTER TABLE ean_hotels SET SCHEMA providers;
ALTER TABLE ean_hotel_images SET SCHEMA providers;
ALTER TABLE ean_hotel_attribute_links SET SCHEMA providers;
ALTER TABLE ean_hotel_attributes SET SCHEMA providers;
ALTER TABLE ean_hotel_descriptions SET SCHEMA providers;
ALTER TABLE ean_points_of_interest_coordinates SET SCHEMA providers;
ALTER TABLE ean_region_coordinates SET SCHEMA providers;
ALTER TABLE ean_regions SET SCHEMA providers;
ALTER TABLE ean_room_types SET SCHEMA providers;
ALTER TABLE ean_countries SET SCHEMA providers;


ALTER TABLE etb_cities SET SCHEMA providers;
ALTER TABLE etb_countries SET SCHEMA providers;
ALTER TABLE etb_facilities SET SCHEMA providers;
ALTER TABLE etb_hotel_descriptions SET SCHEMA providers;
ALTER TABLE etb_hotel_facilities SET SCHEMA providers;
ALTER TABLE etb_hotel_images SET SCHEMA providers;
ALTER TABLE etb_hotels SET SCHEMA providers;
ALTER TABLE etb_points_of_interests SET SCHEMA providers;
ALTER TABLE etb_provinces SET SCHEMA providers;
ALTER TABLE etb_rooms SET SCHEMA providers;

ALTER TABLE late_rooms_amenities SET SCHEMA providers;
ALTER TABLE late_rooms_hotel_amenities SET SCHEMA providers;
ALTER TABLE late_rooms_hotel_images SET SCHEMA providers;
ALTER TABLE late_rooms_hotels SET SCHEMA providers;


ALTER TABLE splendia_amenities SET SCHEMA providers;
ALTER TABLE splendia_hotel_amenities SET SCHEMA providers;
ALTER TABLE splendia_hotels SET SCHEMA providers;

ALTER TABLE venere_amenities SET SCHEMA providers;
ALTER TABLE venere_hotel_amenities SET SCHEMA providers;
ALTER TABLE venere_hotel_images SET SCHEMA providers;
ALTER TABLE venere_hotels SET SCHEMA providers;





ALTER TABLE hotel_names SET SCHEMA providers;