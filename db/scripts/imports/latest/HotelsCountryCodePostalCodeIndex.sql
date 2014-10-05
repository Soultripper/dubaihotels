-- Index: idx_countrycode_postalcode

-- DROP INDEX idx_countrycode_postalcode;

CREATE INDEX idx_countrycode_postalcode
  ON hotels
  USING btree
  (country_code COLLATE pg_catalog."default", postal_code COLLATE pg_catalog."default");
