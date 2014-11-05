update provider_hotels set 
  star_rating = case when star_rating = 0 then null else star_rating end ,
  user_rating = case when user_rating = 0 then null else user_rating end ,
  amenities =   case when amenities = 0 then null else amenities end 

update hotels h set
provider_hotel_count = providers.count,
star_rating = providers.star_rating,
user_rating = providers.user_rating,
amenities = providers.amenities
FROM
(
  SELECT hotel_id,
  count(*) AS count,
  AVG(star_rating) AS star_rating,
  AVG(user_rating) AS user_rating,
  bit_or(amenities) AS amenities
  FROM provider_hotels
  WHERE hotel_id is not NULL
  GROUP By hotel_id
) as providers
WHERE h.id = providers.hotel_id