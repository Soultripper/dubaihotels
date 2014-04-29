/*
	Different tanking methods
		1	Count of pictures
		2	
*/

WITH 
ranking_mechanism_count_pictures(id, normal_name, geog, rank)
AS
(
	SELECT
		H.id,
		H.normal_name,
		H.geog,
		COUNT(*)
	FROM
		hotels AS H
		LEFT JOIN hotel_images AS HI
		ON HI.hotel_id = H.id
	GROUP BY
		H.id,
		H.normal_name,
		H.geog		
),

ranking_mechanism_average_picture_size(id, normal_name, geog, rank)
AS
(
	SELECT
		H.id,
		H.normal_name,
		H.geog,
		AVG(HI.width * HI.height)
	FROM
		hotels AS H
		LEFT JOIN hotel_images AS HI
		ON HI.hotel_id = H.id
	GROUP BY
		H.id,
		H.normal_name,
		H.geog		
)

ranking_mechanism_total_picture_size(id, normal_name, geog, rank)
AS
(
	SELECT
		H.id,
		H.normal_name,
		H.geog,
		SUM(HI.width * HI.height)
	FROM
		hotels AS H
		LEFT JOIN hotel_images AS HI
		ON HI.hotel_id = H.id
	GROUP BY
		H.id,
		H.normal_name,
		H.geog		
)