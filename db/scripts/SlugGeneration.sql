--COUNTRIES

-- Constraint: utility.locations_pkey
-- ALTER TABLE utility.locations ADD COLUMN landmark character varying(255);


/*
	First, clear down all the slugs in the utility.locations table
*/

UPDATE utility.locations SET slug = NULL;

/*
	Then grant the capital city slugs
	133 rows
*/

UPDATE utility.locations AS L
SET
	Slug = city
FROM	
	utility.capitalcities AS CC
WHERE 
	L.country = cc.country
AND 
	L.city = cc.capital;

-- Populate Landmarks
UPDATE utility.locations
SET
	slug = LOWER(COALESCE(landmark, ''))
WHERE 
	slug IS NULL
AND 
	landmark IS NOT NULL;
	
-- Populate Countries
UPDATE utility.locations
SET
	slug = LOWER(COALESCE(country, ''))
WHERE 
	slug IS NULL
AND 
	city IS NULL 
AND 
	region IS NULL 
AND 
	country IS NOT NULL;

/*
	Un-grant the duplicates :(

	SELECT 	*, ROW_NUMBER() OVER(PARTITION BY country ORDER BY Id)
	FROM utility.locations WHERE slug IS NOT NULL
	ORDER BY City
*/	

UPDATE utility.locations SET slug = NULL WHERE city = 'Beirut' AND region = 'Beirut Governorate';
UPDATE utility.locations SET slug = NULL WHERE city = 'Copenhagen' AND region = 'Sjælland island';
UPDATE utility.locations SET slug = NULL WHERE city = 'Washington' AND region <> 'District of Columbia';

/*
	Award other city names, based on hotel star sum
	Note that the city names are only awarded if there's no capital by that name, to keep slugs unique
	Appx 54k rows
*/

UPDATE utility.locations AS L
SET
	slug = T3.city
FROM
(
	SELECT *
	FROM
	(
		SELECT 
			*,
			ROW_NUMBER() OVER(PARTITION BY city ORDER BY sumstars DESC) AS preference
		FROM
		(
			SELECT
				country_code, city, SUM(star_rating) AS sumstars
			FROM
				public.hotels
			WHERE
				city NOT IN (SELECT slug FROM utility.locations WHERE slug IS NOT NULL)
			GROUP BY
				country_code, city
		) AS T1
	) AS T2
	WHERE T2.preference = 1
)AS T3
WHERE
	L.slug IS NULL
AND
	L.city = T3.city
AND
	L.country_code = T3.country_code;

/*
	Remove any duplicates (appx 3700 rows)
*/

UPDATE utility.locations AS L
SET
	slug = NULL
FROM
(
	SELECT 
		id
	FROM
	(
		SELECT 
			*,
			ROW_NUMBER() OVER(PARTITION BY slug ORDER BY slug) AS slugcounter
		FROM
			utility.locations
		WHERE
			slug IS NOT NULL
	) AS T1
	WHERE slugcounter > 1
) AS T2
WHERE
	T2.id = L.id;
/*
	Fill in with region/country where this no city
	Appx 1700 rows
*/

UPDATE utility.locations
SET
	slug = LOWER(COALESCE(region, '')) || '-' || LOWER(COALESCE(country, ''))
WHERE
	slug IS NULL
AND
	city IS NULL
AND
	region IS NOT NULL;

/*
	Fill in with city/country where this a city
	Appx 8k rows
*/

UPDATE utility.locations
SET
	slug = LOWER(COALESCE(city, '')) || '-' || LOWER(COALESCE(country, ''))
WHERE
	slug IS NULL
AND
	city IS NOT NULL;


	
/*
	Remove dupes from the city/country sweep
	Appx 3k rows
*/

UPDATE utility.locations AS L
SET
	slug = NULL
FROM
(
	SELECT 
		city, country_code
	FROM
	(
		SELECT 
			*,
			ROW_NUMBER() OVER(PARTITION BY slug ORDER BY slug) AS slugcounter
		FROM
			utility.locations
		WHERE
			slug IS NOT NULL
	) AS T1
	WHERE slugcounter > 1
) AS T2
WHERE
	T2.country_code = L.country_code
AND
	COALESCE(T2.city, '') = COALESCE(L.city, '');

/*
	Final sweep is city/region/country
*/

UPDATE utility.locations
SET
	slug = LOWER(COALESCE(city, '')) || '-' || LOWER(COALESCE(region, '')) || '-' || LOWER(COALESCE(country, ''))
WHERE
	slug IS NULL;

/*
	Observe duplicates

	SELECT
	slug, COUNT(*)
	FROM utility.locations 
	group by slug having count(*) > 1
	ORDER BY 2 DESC
*/
	
/*
	Tidy up the slugs
*/

UPDATE utility.locations
SET
	slug = LOWER(slug);


UPDATE utility.locations
SET
	slug = REPLACE(slug, ' ', '-');	

/*
	Copy across slugs
*/

UPDATE public.locations AS P
SET
	slug = U.slug
FROM
	utility.locations AS U
WHERE
	U.Id = P.Id

	