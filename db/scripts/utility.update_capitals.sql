-- Function: utility.update_capitals()

-- DROP FUNCTION utility.update_capitals();

CREATE OR REPLACE FUNCTION utility.update_capitals()
  RETURNS void AS
$BODY$UPDATE utility.locations SET is_capital = B'0'::bit(1);

UPDATE utility.locations AS L
SET
	is_capital = B'1'::bit(1)
FROM	
	utility.capitalcities AS CC
WHERE 
	L.country = cc.country
AND 
	L.city = cc.capital;

UPDATE utility.locations SET is_capital = B'0'::bit(1) WHERE city = 'Beirut' AND region = 'Beirut Governorate';
UPDATE utility.locations SET is_capital = B'0'::bit(1) WHERE city = 'Copenhagen' AND region = 'Sjælland island';
UPDATE utility.locations SET is_capital = B'0'::bit(1) WHERE city = 'Washington' AND region <> 'District of Columbia';

UPDATE public.locations AS PL
SET
	is_capital = UL.is_capital
FROM
	utility.locations AS UL
WHERE
	UL.Id = PL.Id;$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION utility.update_capitals()
  OWNER TO u1uf61dvp27blk;
