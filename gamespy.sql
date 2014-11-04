/*-----------------------------------------------------------------
					   STORES TABLE:
-------------------------------------------------------------------
 Contains all information on any store on the system, users are able
 to search by store location via a post code, or they can perform
 a more generic search by store name
-------------------------------------------------------------------*/
CREATE TABLE stores
(
	store_id	NUMBER(5)
				CONSTRAINT stores_store_id_pk
					PRIMARY KEY
				CONSTRAINT stores_store_id_nn
					NOT NULL,
	name 		VARCHAR2(50)
				CONSTRAINT stores_name_nn
					NOT NULL,
	description VARCHAR2(4000)
				CONSTRAINT sotres_description_nn
					NOT NULL,
	postcode	VARCHAR2(10)
				CONSTRAINT stores_postcode_chk
					CHECK(TRIM(REGEXP_LIKE(
							'([A-PR-UWYZ0-9][A-HK-Y0-9][AEHMNPRTVXY0-9]?[ABEHMNPRVWXY0-9]{1,2}[0-9][ABD-HJLN-UW-Z]{2}|GIR 0AA)'
						)))
				CONSTRAINT stores_postcode_nn
					NOT NULL

);

/*-----------------------------------------------------------------
					  CONSOLES TABLE:
-------------------------------------------------------------------
 Contains all information on any console stored on the system, 
 stores are able to reference each console independently via its
 console_id, they are also able to set their own additional 
 description and sales price through their items table.
-------------------------------------------------------------------*/
CREATE TABLE consoles
(
	console_id 	NUMBER(5)
				CONSTRAINT consoles_console_id_pk
					PRIMARY KEY
				CONSTRAINT consoles_console_id_nn
					NOT NULL,
	manufac     NUMBER(5) 
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
	rr_price    NUMBER
				CONSTRAINT consoles_rr_price_nn
					NOT NULL,
	description VARCHAR2(4000)
				CONSTRAINT consoles_description_nn
					NOT NULL,
	tags		VARCHAR2(500)
);

/*-----------------------------------------------------------------
					    GAMES TABLE:
-------------------------------------------------------------------
 Contains all information on any games stored in the system, the
 system will perform searches against the descriptions given in 
 the items on text search.
 Stores are able to add their own description for each item as well
 as amend the price, overriding the default samples inputted here.
-------------------------------------------------------------------*/
CREATE TABLE games
(
	game_id 	NUMBER(5)
				CONSTRAINT games_id_pk
					PRIMARY KEY
				CONSTRAINT games_id_nn
					NOT NULL,
	category    NUMBER(5)
				CONSTRAINT games_category_fk
					REFERENCES categories(category_id)
				CONSTRAINT games_category_nn
					NOT NULL,
	title		VARCHAR2(100)
				CONSTRAINT games_title_nn
					NOT NULL,
	release     DATE
				CONSTRAINT games_release_nn
					NOT NULL,
	description VARCHAR2(4000)
				CONSTRAINT games_description_nn
					NOT NULL,
	tags        VARCHAR2(500),
	rr_price    NUMBER
);

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