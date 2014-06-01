/*
	Generating normal name for matching
*/

ALTER TABLE hotels ADD COLUMN normal_name text;

UPDATE hotels SET normal_name = LOWER(name);

UPDATE hotels SET normal_name = REGEXP_REPLACE(normal_name, '\([^)]*\)', '') WHERE normal_name ~ '\([^)]*\)';

UPDATE hotels SET normal_name = REGEXP_REPLACE(normal_name, '(?i)(hotel)' , '') WHERE normal_name ILIKE '%hotel%';

UPDATE hotels SET normal_name = REGEXP_REPLACE(normal_name, '(?i)(and)' , '') WHERE normal_name ILIKE '%and%';

UPDATE hotels SET normal_name = REGEXP_REPLACE(normal_name, '(?i)(the)' , '') WHERE normal_name ILIKE '%the%';

UPDATE hotels SET normal_name = REGEXP_REPLACE(normal_name, '(?i)(apartments)' , '') WHERE normal_name ILIKE '%apartments%';

UPDATE hotels SET normal_name = REGEXP_REPLACE(normal_name, '(?i)(apartment)' , '') WHERE normal_name ILIKE '%apartment%';

UPDATE hotels SET normal_name = REPLACE(normal_name, ' ', '');

CREATE INDEX normal_name_trigram_idx ON hotels USING gist (normal_name gist_trgm_ops);
