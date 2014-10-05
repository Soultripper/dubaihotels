/*
	Script to call the UPSERT stored procedure
*/

/*
	Clear down first:

	TRUNCATE TABLE hotels_test;
	UPDATE provider_hotels_test SET Hotel_Id = NULL;
  VACUUM FULL hotels_test;
  VACUUM FULL provider_hotels_test;

	Remember to VACUUM FULL after this.

*/

SELECT providers.upsert_provider_hotels_to_hotels_test ('booking'); --80s
SELECT providers.upsert_provider_hotels_to_hotels_test ('easy_to_book'); --190s
SELECT providers.upsert_provider_hotels_to_hotels_test ('venere'); --108s
SELECT providers.upsert_provider_hotels_to_hotels_test ('agoda'); --53s
SELECT providers.upsert_provider_hotels_to_hotels_test ('laterooms'); --57s
SELECT providers.upsert_provider_hotels_to_hotels_test ('splendia'); -- 30s
SELECT providers.upsert_provider_hotels_to_hotels_test ('expedia'); --346s