-- Index: idx_provider_hotel_images_hotel_id

DROP INDEX idx_provider_hotel_images_hotel_id;
DROP INDEX idx_provider_hotel_images_provider_provider_id;


update provider_hotel_images set default_image = null where provider = 'expedia';

update provider_hotel_images phi
set default_image = t1.default_image
from
(select ean_hotel_id, url, thumbnail_url, default_image from providers.ean_hotel_images) as T1
where T1.ean_hotel_id = phi.provider_id and t1.url = phi.url and phi.provider = 'expedia';


CREATE INDEX idx_provider_hotel_images_hotel_id
  ON provider_hotel_images
  USING btree
  (hotel_id);


-- Index: idx_provider_hotel_images_provider_provider_id


CREATE INDEX idx_provider_hotel_images_provider_provider_id
  ON provider_hotel_images
  USING btree
  (provider COLLATE pg_catalog."default", provider_id);
ALTER TABLE provider_hotel_images CLUSTER ON idx_provider_hotel_images_provider_provider_id;
-- Index: index_hotel_images_v2_on_provider


update hotels set image_url = null, thumbnail_url = null 
where position('expedia.com' in image_url) > 0

UPDATE hotels SET image_url = T1.url, thumbnail_url = T1.thumbnail_url
FROM
(
  SELECT hotel_id, url, thumbnail_url 
  FROM provider_hotel_images phi 
  WHERE phi.default_image = true AND phi.provider = 'expedia' AND hotel_id IS NOT NULL
) AS T1
WHERE image_url is null  AND T1.hotel_id = id;

