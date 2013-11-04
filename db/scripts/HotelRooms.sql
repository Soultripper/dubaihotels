/*
	Create the new table
*/
CREATE TABLE hotel_rooms
(
  id serial NOT NULL,
  hotel_id integer,
  room_type_id integer,
  language_code character varying(255),
  image character varying(255),
  name character varying(255),
  description text,
  CONSTRAINT hotel_rooms_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE hotel_rooms
  OWNER TO u1uf61dvp27blk;

/*
	Populate the new table

	NOTE: Not sure this makes sense as a generic hotel room, 
	but with 102k distinct room names it's not a trivial task

	508465 rows
*/

INSERT INTO hotel_rooms
(hotel_id, room_type_id, language_code, image, name, description)
SELECT 
	h.id, room_type_id, language_code, image, ERT.name, ERT.description
FROM ean_room_types AS ERT
INNER JOIN ean_hotels AS EH
ON EH.id = ERT.ean_hotel_id
INNER JOIN hotels AS H
ON H.ean_hotel_id = EH.id;

/*
	Are hotel room names suppose to be normalised, like
	the amenities were?
*/

