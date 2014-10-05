UPDATE hotels h
SET slug =   REGEXP_REPLACE(REGEXP_REPLACE(REPLACE(REPLACE(REPLACE(lower(UNACCENT(h.name)),'&', 'and'), 'bandb', 'b and b'), ' ', '-'), '[^\w|-]','','ig'), '-{2}','');

UPDATE hotels
SET slug = slug || '-' || hotels.id
FROM
  (
    SELECT 
      id,
      ROW_NUMBER() OVER(PARTITION BY slug ORDER BY provider_hotel_count DESC, COALESCE(provider_hotel_ranking,0) DESC, COALESCE(user_rating,0) DESC, COALESCE(star_rating, 0) DESC) AS preference
    FROM 
      hotels
  ) AS T1
WHERE hotels.id = T1.id AND  T1.preference > 1