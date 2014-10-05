-- CLEAR DOWN Hotel_ids
UPDATE provider_hotel_images phi SET hotel_id = null;
-- Reassign
UPDATE provider_hotel_images phi
SET hotel_id = T1.hotel_id
FROM 
(
  SELECT hotel_id, provider, provider_id FROM provider_hotels
) AS T1
WHERE T1.provider = phi.provider AND T1.provider_id = phi.provider_id;

-- Try Expedia first
UPDATE hotels SET image_url = T1.url, thumbnail_url = T1.thumbnail_url
FROM
(
  SELECT hotel_id, url, thumbnail_url 
  FROM provider_hotel_images phi 
  WHERE phi.default_image = true AND phi.provider = 'expedia'
) AS T1
WHERE COALESCE(image_url,'') ='' AND T1.hotel_id = id;

UPDATE hotels SET image_url = T1.url, thumbnail_url = T1.thumbnail_url
FROM
(
  SELECT hotel_id, url, thumbnail_url 
  FROM provider_hotel_images phi 
  WHERE phi.default_image = true AND phi.provider = 'booking'
) AS T1
WHERE COALESCE(image_url,'') =''  AND T1.hotel_id = id;

UPDATE hotels SET image_url = T1.url, thumbnail_url = T1.thumbnail_url
FROM
(
  SELECT hotel_id, url, thumbnail_url 
  FROM provider_hotel_images phi 
  WHERE phi.default_image = true AND phi.provider = 'venere'
) AS T1
WHERE COALESCE(image_url,'') =''  AND T1.hotel_id = id;

UPDATE hotels SET image_url = T1.url, thumbnail_url = T1.thumbnail_url
FROM
(
  SELECT hotel_id, url, thumbnail_url 
  FROM provider_hotel_images phi 
  WHERE phi.default_image = true AND phi.provider = 'easy_to_book'
) AS T1
WHERE COALESCE(image_url,'') =''  AND T1.hotel_id = id;

UPDATE hotels SET image_url = T1.url, thumbnail_url = T1.thumbnail_url
FROM
(
  SELECT hotel_id, url, thumbnail_url 
  FROM provider_hotel_images phi 
  WHERE phi.default_image = true AND phi.provider = 'laterooms'
) AS T1
WHERE COALESCE(image_url,'') =''  AND T1.hotel_id = id;


UPDATE hotels SET image_url = T1.url, thumbnail_url = T1.thumbnail_url
FROM
(
  SELECT hotel_id, url, thumbnail_url 
  FROM provider_hotel_images phi 
  WHERE phi.default_image = true AND phi.provider = 'agoda'
) AS T1
WHERE COALESCE(image_url,'') =''  AND T1.hotel_id = id;