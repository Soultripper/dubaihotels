INSERT INTO hotel_images
(
	hotel_id,
	caption,
	url,
	width,
	height,
	byte_size,
	thumbnail_url,
	default_image
)
SELECT
	H.id,
	'ETB' || EHI.size, 
	image,
	NULL,
	NULL,
	NULL,
	image,
	false
FROM
	hotels AS H
	INNER JOIN etb_hotels AS EH
	ON H.etb_hotel_id = EH.id
	INNER JOIN etb_hotel_images AS EHI
	ON EHI.etb_hotel_id = EH.id
	LEFT JOIN hotel_images AS HI
	ON HI.hotel_id = H.id
WHERE
	HI.id IS NULL


/*
What hotels did this affect?

SELECT DISTINCT H.*
FROM
	Hotels AS H
	INNER JOIN hotel_images AS HI
	ON H.Id = HI.hotel_id
WHERE
	etb_hotel_id IS NOT NULL
AND
	HI.thumbnail_url is null
LIMIT 1000
*/