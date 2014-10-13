
CREATE INDEX idx_hotels_geog_name_normal
  ON hotels
  USING btree
  (geog, name_normal COLLATE pg_catalog."default");
ALTER TABLE hotels CLUSTER ON idx_hotels_geog_name_normal;

-- Index: idx_provider_hotels_provider_name_normal_geo

-- DROP INDEX idx_provider_hotels_provider_name_normal_geo;

CREATE INDEX idx_provider_hotels_provider_name_normal_geo
  ON provider_hotels
  USING btree
  (provider COLLATE pg_catalog."default", geog, name_normal COLLATE pg_catalog."default");
ALTER TABLE provider_hotels CLUSTER ON idx_provider_hotels_provider_name_normal_geo;


truncate table hotels;
vacuum full hotels;
update provider_hotels set hotel_id = null;
vacuum full provider_hotels;
reindex table provider_hotels;
reindex table hotels;


WITH InsertCTE AS
(
  INSERT INTO hotels (name, address, city, state_province, postal_code, country_code,  latitude, longitude, geog, description, star_rating, amenities,  image_url, thumbnail_url, user_rating, provider_hotel_id, provider_hotel_ranking, name_normal)
  SELECT name, address, city, state_province, postal_code, country_code,  latitude, longitude, geog, description, star_rating, amenities,null,null,user_rating, id, ranking, normalise_name(name)
  FROM provider_hotels 
  WHERE provider = 'booking'
  AND hotel_id IS NULL
  RETURNING id, provider_hotel_id
)

UPDATE provider_hotels AS p
SET hotel_id = i.id 
FROM InsertCTE AS I
WHERE I.provider_hotel_id::integer = p.id;

vacuum full hotels;
reindex table hotels;




SELECT providers.update_provider_hotels_to_hotels_postcode_based ('expedia'); --346s
SELECT providers.update_provider_hotels_to_hotels_postcode_based ('venere'); --108s
SELECT providers.update_provider_hotels_to_hotels_postcode_based ('agoda'); --53s
SELECT providers.update_provider_hotels_to_hotels_postcode_based ('laterooms'); --57s
SELECT providers.update_provider_hotels_to_hotels_postcode_based ('easy_to_book'); --190s
SELECT providers.update_provider_hotels_to_hotels_postcode_based ('splendia'); -- 30s


vacuum full hotels;
reindex table hotels;
reindex table provider_hotels;


SELECT providers.update_provider_hotels_to_hotels_distance_based ('expedia'); --346s
SELECT providers.update_provider_hotels_to_hotels_distance_based ('venere'); --108s
SELECT providers.update_provider_hotels_to_hotels_distance_based ('agoda'); --53s
SELECT providers.update_provider_hotels_to_hotels_distance_based ('laterooms'); --57s
SELECT providers.update_provider_hotels_to_hotels_distance_based ('easy_to_book'); --190s
SELECT providers.update_provider_hotels_to_hotels_distance_based ('splendia'); -- 30s