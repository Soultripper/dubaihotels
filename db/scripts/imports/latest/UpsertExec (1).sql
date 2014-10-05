/*
	Script to call the UPSERT stored procedure
*/

/*
	Clear down first:

	TRUNCATE TABLE hotels;
	UPDATE provider_hotels SET Hotel_Id = NULL;

	Remember to VACUUM FULL after this.

*/

SELECT providers.upsert_provider_hotels_to_hotels ('booking'); --80s
SELECT providers.upsert_provider_hotels_to_hotels ('easy_to_book'); --190s
SELECT providers.upsert_provider_hotels_to_hotels ('venere'); --108s
SELECT providers.upsert_provider_hotels_to_hotels ('agoda'); --53s
SELECT providers.upsert_provider_hotels_to_hotels ('laterooms'); --57s
SELECT providers.upsert_provider_hotels_to_hotels ('splendia'); -- 30s
SELECT providers.upsert_provider_hotels_to_hotels ('expedia'); --346s