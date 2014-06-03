  
-- INIT temp table
CREATE TABLE hotels_temp AS SELECT * FROM hotels;


CREATE INDEX hotels_city_country_code_idx_temp  ON hotels_temp USING btree (city COLLATE pg_catalog."default", country_code COLLATE pg_catalog."default");
  ALTER TABLE hotels_temp CLUSTER ON hotels_city_country_code_idx_temp;
CREATE INDEX hotels_geog_idx_temp                ON hotels_temp USING gist (geog);
CREATE INDEX hotels_slug_idx_temp                  ON hotels_temp USING btree (slug COLLATE pg_catalog."default");
CREATE INDEX hotels_state_province_idx_temp  ON hotels_temp USING btree (state_province COLLATE pg_catalog."default");
CREATE INDEX matches_ranking_idx_temp         ON hotels_temp USING btree (matches DESC NULLS LAST, ranking DESC NULLS LAST);

-- Has to be run separately
VACUUM ANALYZE VERBOSE hotels_temp;

-- move live to backup
ALTER INDEX hotels_city_country_code_idx rename to hotels_city_country_code_idx_backup;
ALTER INDEX hotels_geog_idx                RENAME TO hotels_geog_idx_backup;
ALTER INDEX hotels_slug_idx                 RENAME TO hotels_slug_idx_backup;
ALTER INDEX hotels_state_province_idx RENAME TO hotels_state_province_idx_backup;
ALTER INDEX matches_ranking_idx        RENAME TO matches_ranking_idx_backup;
ALTER TABLE hotels                               RENAME TO hotels_backup;

-- Move temp over to live
ALTER TABLE hotels_temp                     RENAME TO hotels;

ALTER INDEX hotels_city_country_code_idx_temp   rename to hotels_city_country_code_idx;
ALTER INDEX hotels_geog_idx_temp                       RENAME TO hotels_geog_idx;
ALTER INDEX hotels_slug_idx_temp                        RENAME TO hotels_slug_idx;
ALTER INDEX hotels_state_province_idx_temp        RENAME TO hotels_state_province_idx;
ALTER INDEX matches_ranking_idx_temp              RENAME TO matches_ranking_idx;


-- IF ALL OK DROP BACKUP

DROP INDEX hotels_city_country_code_idx_backup;
DROP INDEX hotels_geog_idx_backup;
DROP INDEX hotels_slug_idx_backup;
DROP INDEX hotels_state_province_idx_backup;
DROP INDEX matches_ranking_idx_backup;
DROP TABLE hotels_backup;

-- ELSE REVERT

DROP INDEX hotels_city_country_code_idx;
DROP INDEX hotels_geog_idx;
DROP INDEX hotels_slug_idx;
DROP INDEX hotels_state_province_idx;
DROP INDEX matches_ranking_idx;
DROP TABLE hotels;


ALTER TABLE hotels_backup                     RENAME TO hotels;

ALTER INDEX hotels_city_country_code_idx_backup   rename to hotels_city_country_code_idx;
ALTER INDEX hotels_geog_idx_backup                       RENAME TO hotels_geog_idx;
ALTER INDEX hotels_slug_idx_backup                        RENAME TO hotels_slug_idx;
ALTER INDEX hotels_state_province_idx_backup        RENAME TO hotels_state_province_idx;
ALTER INDEX matches_ranking_idx_backup                RENAME TO matches_ranking_idx;