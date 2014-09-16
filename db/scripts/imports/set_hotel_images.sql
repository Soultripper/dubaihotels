UPDATE hotels SET image_url = T1.url, thumbnail_url = T1.thumbnail_url
FROM
(
  SELECT hotel_id, url, thumbnail_url 
  FROM provider_hotel_images phi 
  WHERE phi.default_image = true AND phi.provider = 'expedia'
) AS T1
WHERE image_url IS NULL AND T1.hotel_id = id