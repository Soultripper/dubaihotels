SELECT
	unnest(string_to_array(name, ' ')), COUNT(*)
FROM	
	hotels
GROUP BY
	unnest(string_to_array(name, ' '))
ORDER BY COUNT(*) DESC
LIMIT 100