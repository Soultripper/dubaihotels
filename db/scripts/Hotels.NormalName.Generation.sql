/*
	Generating normal name for matching
*/

ALTER TABLE hotels ADD COLUMN normal_name text;

UPDATE hotels SET normal_name = REPLACE(REPLACE(LOWER(name), '&', 'and'), ',', '');
UPDATE hotels SET normal_name = REGEXP_REPLACE(normal_name, '\([^)]*\)', '') WHERE normal_name ~ '\([^)]*\)';
UPDATE hotels SET normal_name = REGEXP_REPLACE(normal_name, '(\s+hotel$)' , '') WHERE normal_name ~ '\s+hotel$';
UPDATE hotels SET normal_name = REPLACE(normal_name, LOWER(city) , '')

UPDATE hotels SET normal_name = REPLACE(normal_name, ' ', '');

CREATE INDEX normal_name_trigram_idx ON hotels USING gist (normal_name gist_trgm_ops);
