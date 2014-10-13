-- CLEAR DOWN Hotel_ids
UPDATE provider_hotel_images phi SET hotel_id = null;
-- Reassign

update hotels set image_url = null, thumbnail_url = null where image_url=''


vacuum full provider_hotel_images;
reindex table provider_hotel_images;

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
  WHERE phi.default_image = true AND phi.provider = 'expedia' AND hotel_id IS NOT NULL
) AS T1
WHERE image_url is null  AND T1.hotel_id = id;

UPDATE hotels SET image_url = T1.url, thumbnail_url = T1.thumbnail_url
FROM
(
  SELECT hotel_id, url, thumbnail_url 
  FROM provider_hotel_images phi 
  WHERE phi.default_image = true AND phi.provider = 'booking' AND hotel_id IS NOT NULL
) AS T1
WHERE image_url is null  AND T1.hotel_id = id;


UPDATE hotels SET image_url = T1.url, thumbnail_url = T1.thumbnail_url
FROM
(
  SELECT hotel_id, url, thumbnail_url 
  FROM provider_hotel_images phi 
  WHERE phi.default_image = true AND phi.provider = 'agoda' AND hotel_id IS NOT NULL
) AS T1
WHERE image_url is null  AND T1.hotel_id = id;

UPDATE hotels SET image_url = T1.url, thumbnail_url = T1.thumbnail_url
FROM
(
  SELECT hotel_id, url, thumbnail_url 
  FROM provider_hotel_images phi 
  WHERE phi.default_image = true AND phi.provider = 'venere' AND hotel_id IS NOT NULL
) AS T1
WHERE image_url is null  AND T1.hotel_id = id;


UPDATE hotels SET image_url = T1.url, thumbnail_url = T1.thumbnail_url
FROM
(
  SELECT hotel_id, url, thumbnail_url 
  FROM provider_hotel_images phi 
  WHERE phi.default_image = true AND phi.provider = 'laterooms' AND hotel_id IS NOT NULL
) AS T1
WHERE image_url is null  AND T1.hotel_id = id;

UPDATE hotels SET image_url = T1.url, thumbnail_url = T1.thumbnail_url
FROM
(
  SELECT hotel_id, url, thumbnail_url 
  FROM provider_hotel_images phi 
  WHERE phi.default_image = true AND phi.provider = 'splendia' AND hotel_id IS NOT NULL
) AS T1
WHERE image_url is null  AND T1.hotel_id = id;

UPDATE hotels SET image_url = T1.url, thumbnail_url = T1.thumbnail_url
FROM
(
  SELECT hotel_id, url, thumbnail_url 
  FROM provider_hotel_images phi 
  WHERE phi.default_image = true AND phi.provider = 'easy_to_book' AND hotel_id IS NOT NULL
) AS T1
WHERE image_url is null  AND T1.hotel_id = id;
