--General validation query
SELECT
	H.id,
	H.nameaddress,
	E.id,
	E.nameaddress,
	W.weighting
FROM
	hotels AS H
	INNER JOIN hotels_ean_hotels_matches_weighted_staging AS W
	ON W.hotel_id = h.id
	INNER JOIN ean_hotels AS E
	ON E.Id = W.ean_hotel_id
ORDER BY Weighting DESC
LIMIT 100

--Where does it disagree with the previous methodology
SELECT
	H.id,
	H.nameaddress,
	H.ean_hotel_id,
	E.id,
	E.nameaddress AS newmethod,
	W.weighting,
	E2.nameaddress AS oldmethod
FROM
	hotels AS H
	INNER JOIN hotels_ean_hotels_matches_weighted_staging AS W
	ON W.hotel_id = h.id
	INNER JOIN ean_hotels AS E
	ON E.Id = W.ean_hotel_id
	INNER JOIN ean_hotels AS E2
	ON E2.Id = H.ean_hotel_id
WHERE
	H.ean_hotel_id <> E.id
ORDER BY Weighting DESC
	