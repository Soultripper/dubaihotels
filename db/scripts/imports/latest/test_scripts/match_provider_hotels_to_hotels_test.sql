-- Function: match_provider_hotels_to_hotels(character varying)

-- DROP FUNCTION match_provider_hotels_to_hotels(character varying);

CREATE OR REPLACE FUNCTION match_provider_hotels_to_hotels_test(provider_name character varying)
  RETURNS void AS
$BODY$
DECLARE
  provider_hotel_record RECORD;
  duplicate_provider_hotels_count INT;
BEGIN

  RAISE NOTICE 'Starting Cursor Procedure';

  IF EXISTS(SELECT * FROM hotels_test) THEN   

    RAISE NOTICE 'Hotels Exist';

    CREATE TEMP TABLE duplicate_provider_hotels(id INTEGER NOT NULL PRIMARY KEY);

    INSERT INTO duplicate_provider_hotels(id)
    SELECT Id 
    FROM
    (
      SELECT Id, ROW_NUMBER() OVER(PARTITION BY hotel_id ORDER BY id) AS RN
      FROM provider_hotels_test

      WHERE provider = provider_name
      AND hotel_id IS NOT NULL
      AND hotel_id IN
      (
        SELECT hotel_id
        FROM provider_hotels_test
        WHERE provider = provider_name
        AND hotel_id IS NOT NULL
        GROUP BY hotel_id
        HAVING COUNT(*) > 1 
      )
    ) AS T2
    WHERE RN > 1
    ORDER BY Id;

    RAISE NOTICE 'Inserted to temp table';

    duplicate_provider_hotels_count := (SELECT COUNT(*) FROM duplicate_provider_hotels);

    RAISE NOTICE 'Counted temp table';
    
    WHILE(duplicate_provider_hotels_count > 0) LOOP

      RAISE NOTICE 'In Cursor Loop, % records this cycle', duplicate_provider_hotels_count;
      
      UPDATE provider_hotels_test
      SET hotel_id = NULL
      WHERE id IN (SELECT id FROM duplicate_provider_hotels);

      UPDATE provider_hotels_test AS p
      SET hotel_id = h.id
      FROM 
      (
        SELECT h.id, p.id AS hotel_provider_id, 
        ROW_NUMBER() OVER(PARTITION BY p.id ORDER BY ST_Distance(p.geog, h.geog) ASC, SIMILARITY(p.name_normal, h.name_normal) DESC, SIMILARITY(p.address, h.address) DESC) AS Ranking
        FROM hotels_test AS h
        INNER JOIN provider_hotels_test AS p
        --ON p.name_normal = REGEXP_REPLACE(REPLACE(lower(h.name), lower(COALESCE(h.city, '')), ''), '\y(the|hotel|inn|by|apartments|apartment|B&B|and|hostel|villa|de|le|motel|guest|bed|breakfast|suites|spa|")\y|\W', '', 'ig')
        ON (ST_Distance(p.geog, h.geog) < 300 AND SIMILARITY(p.name_normal, h.name_normal) > 0.35) --AND SIMILARITY(p.address, h.address)
        AND p.hotel_id IS NULL
        AND p.provider = provider_name
        INNER JOIN duplicate_provider_hotels AS d
        ON d.id = p.id
        WHERE NOT EXISTS(SELECT * FROM provider_hotels_test WHERE provider = provider_name and hotel_id = h.id)
      ) AS H
      WHERE p.id = h.hotel_provider_id
      AND p.hotel_id IS NULL
      AND h.Ranking = 1
      AND p.provider = provider_name; 

      TRUNCATE TABLE duplicate_provider_hotels;

      INSERT INTO duplicate_provider_hotels(id)
      SELECT Id 
      FROM
      (
        SELECT Id, ROW_NUMBER() OVER(PARTITION BY hotel_id ORDER BY id) AS RN
        FROM provider_hotels_test

        WHERE provider = provider_name
        AND hotel_id IS NOT NULL
        AND hotel_id IN
        (
          SELECT hotel_id
          FROM provider_hotels_test
          WHERE provider = provider_name
          AND hotel_id IS NOT NULL
          GROUP BY hotel_id
          HAVING COUNT(*) > 1 
        )
      ) AS T2
      WHERE RN > 1
      ORDER BY Id;

      duplicate_provider_hotels_count := (SELECT COUNT(*) FROM duplicate_provider_hotels);
        
    END LOOP;

    DROP TABLE duplicate_provider_hotels;

  END IF;

  RAISE NOTICE 'Leaving Cursor Procedure';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
--ALTER FUNCTION match_provider_hotels_to_hotels(character varying OWNER TO postgres;
