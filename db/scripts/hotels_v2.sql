-- POPULATE
-- INSERT INTO hotels_v2 (name, address, city, state_province, postal_code, country_code,  latitude, longitude, geog, description, star_rating, amenities,  image_url, thumbnail_url, user_rating, score,  provider_hotel_ranking, provider_hotel_count, slug)
-- SELECT  name, address, city, state_province, postal_code, country_code,   latitude, longitude, geog, description, star_rating, amenities, image_url, thumbnail_url, user_rating, score, ranking, matches, slug
-- FROM hotels;

INSERT INTO hotels_v2 (name, address, city, state_province, postal_code, country_code,  latitude, longitude, geog, description, star_rating, amenities,  image_url, thumbnail_url, user_rating, provider_hotel_id, provider_hotel_ranking)
SELECT name, address, city, state_province, postal_code, country_code,  latitude, longitude, geog, description, star_rating_normal, amenities,null,null,user_rating_normal, id, ranking
FROM provider_hotels WHERE provider_id = 'booking'


UPDATE provider_hotels
SELECT * FROM provider_hotels ORDER BY latitude, longitude LIMIT 100

SELECT * 
FROM provider_hotels lhs
JOIN
(
	SELECT id, geog, name_normal
	FROM provider_hotels
	ORDER BY latitude, longitude LIMIT 100
) AS rhs
ON lhs.name_normal = rhs.name_normal
AND ST_DWithin(lhs.geog, rhs.geog, 100)


GROUP BY name_normal, 
ORDER BY latitude, longitude 
LIMIT 100x

select * from provider_hotels where id in(806642,
954671,
135572,
301809)

select * from provider_hotels where name like 'The Maid%'

select * from provider_hotels ph
join hotel_images_v2 img on img.provider = ph.provider_id and img.provider_id = ph.provider_hotel_id
where ph.hotel_id = 77547
order by img.default_image desc

select * from booking_hotel_images where booking_hotel_id = 234387