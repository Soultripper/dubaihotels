-- Index: "idx_provider_Id_hotel_id"

-- DROP INDEX "idx_provider_Id_hotel_id";

CREATE INDEX "idx_provider_Id_hotel_id"
  ON provider_hotels
  USING btree
  (provider COLLATE pg_catalog."default", hotel_id);
