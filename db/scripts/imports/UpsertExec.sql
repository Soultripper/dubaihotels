/*
	Script to call the UPSERT stored procedure
*/

SELECT providers.upsert_provider_hotels_to_hotels ('booking');
SELECT providers.upsert_provider_hotels_to_hotels ('expedia');
SELECT providers.upsert_provider_hotels_to_hotels ('easy_to_book');
SELECT providers.upsert_provider_hotels_to_hotels ('venere');
SELECT providers.upsert_provider_hotels_to_hotels ('agoda');
SELECT providers.upsert_provider_hotels_to_hotels ('laterooms');
SELECT providers.upsert_provider_hotels_to_hotels ('splendia');