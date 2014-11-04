CREATE TABLE consoles
(
	console_id 	NUMBER(11)
				CONSTRAINT consoles_console_id_pk
						PRIMARY KEY
				CONSTRAINT consoles_console_id_nn
						NOT NULL,
	manufac     NUMBER(11) 
				CONSTRAINT consoles_manufac_fk
						REFERENCES manufacturers(manufac_id) ON DELETE SET NULL
				CONSTRAINT consoles_manufac_nn
						NOT NULL,
				CONSTRAINT consoles_manufac
	name		VARCHAR2(50)
				CONSTRAINT consoles_name_nn
						NOT NULL,
	release		DATE
				CONSTRAINT consoles_release_nn
						NOT NULL,
	capacity	NUMBER(8) DEFAULT(0)
				CONSTRAINT consoles_capacity_nn
						NOT NULL,
	rr_price    NUMBER(10)
				CONSTRAINT consoles_rr_price_nn
						NOT NULL,
	description VARCHAR2(5000)
				CONSTRAINT consoles_description_nn
						NOT NULL
)

/*-----------------------------------------------------------------
						IMAGES TABLE:
-------------------------------------------------------------------
 Contains all information on an image that can be set for a game, 
 console or store.  
 A foreign key reference exists so that we can set multiple images
 for the same game, console or store. 
 A priority parameter exists to tell us whether we have a COVER 
 (search default) image, or OTHER (screenshots, product angle) image
 which will be displayed on the products gallery page.
-------------------------------------------------------------------*/
CREATE TABLE images
(
	image_id	NUMBER(11)
				CONSTRAINT images_image_id_pk
						PRIMARY KEY
				CONSTRAINT images_image_id_nn
						NOT NULL,
	game_id		NUMBER(11)
				CONSTRAINT images_game_id_fk
						REFERENCES games(game_id) ON DELETE SET NULL,
	console_id  NUMBER(11)
				CONSTRAINT images_console_id_fk
						REFERENCES consoles(console_id) ON DELETE SET NULL,
	filename	VARCHAR(50)
				CONSTRAINT images_filename_nn
						NOT NULL,
	priority    VARCHAR(15)
				CONSTRAINT images_priority_nn
						NOT NULL
				CONSTRAINT images_priority_chk
						CHECK(	UPPER(priority) = 'COVER' OR 
							  	UPPER(priority) = 'OTHER' ),
	image 		ORDIMAGE
				CONSTRAINT images_image_nn 
						NOT NULL,
	thumbnail	BLOB
);