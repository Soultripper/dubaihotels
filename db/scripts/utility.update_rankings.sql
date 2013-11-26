-- Function: utility.update_rankings()

-- DROP FUNCTION utility.update_rankings();

CREATE OR REPLACE FUNCTION utility.update_rankings()
  RETURNS void AS
$BODY$UPDATE utility.locations SET ranking = 0;

UPDATE utility.locations AS L
SET
	ranking = sumstars
FROM
(
	SELECT
		country_code, city, SUM(star_rating) AS sumstars
	FROM
		public.hotels
	GROUP BY
		country_code, city
) AS T1
WHERE
	T1.country_code = L.country_code
AND
	T1.city = L.city;

UPDATE public.locations AS PL
SET
	ranking = UL.ranking
FROM
	utility.locations AS UL
WHERE
	UL.Id = PL.Id; $BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION utility.update_rankings()
  OWNER TO u1uf61dvp27blk;
