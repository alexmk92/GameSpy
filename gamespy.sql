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
				CONSTRAINT stores_postcode_nn
					NOT NULL,
				CONSTRAINT stores_postcode_chk
					CHECK(REGEXP_LIKE(postcode,
							'([A-PR-UWYZ0-9][A-HK-Y0-9][AEHMNPRTVXY0-9]?[ABEHMNPRVWXY0-9]{1,2}[0-9][ABD-HJLN-UW-Z]{2}|GIR 0AA)'
					))			
);

CREATE SEQUENCE seq_store_id START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_stores_before
BEFORE INSERT OR UPDATE ON stores FOR EACH ROW
	BEGIN
	IF INSERTING THEN 
		IF :NEW.store_id IS NULL THEN
			SELECT seq_store_id.nextval
			INTO   :NEW.store_id
			FROM   sys.dual;
		END IF;

		-- Provide any formatting (always remove leading/trailing whitespace)
		:NEW.name        := TRIM(INITCAP(:NEW.name));
		:NEW.description := TRIM(:NEW.description);
		:NEW.postcode    := REPLACE(:NEW.postcode, ' ' , '');
		:NEW.postcode    := TRIM(UPPER(:NEW.postcode));

	END IF;
END;

/*-----------------------------------------------------------------
					   ITEMS TABLE:
-------------------------------------------------------------------
 Contains all the inventory of a given store, each item will either
 be a GAME or CONSOLE, these are represented by their foreign
 key reference.   Stores are able to override the default price
 and descriptions here.

 If the fields store_desc OR store_price are NULL, then they will
 inherit their values from their appropriate item

 -------------------------------------------------------------------
 FK Depencies:
 -------------------------------------------------------------------
 store_id   : is not nullable as we always need to have a reference to
 the current stores stock.

 game_id    : is nullable as it does not always need to be present for 
 an item.

 console_id : is not nullable as game items need to have a platform
 specified for them to be valid (this will help stock control)
-------------------------------------------------------------------*/
CREATE TABLE items
(
	item_id		NUMBER(5)
				CONSTRAINT items_item_id_pk
					PRIMARY KEY
				CONSTRAINT items_item_id_nn
					NOT NULL,
	store_id    CONSTRAINT items_store_id_fk
					REFERENCES stores(store_id)
				CONSTRAINT items_store_id_nn
					NOT NULL,
	game_id     CONSTRAINT items_game_id_fk
					REFERENCES games(game_id),
	console_id  CONSTRAINT items_console_id_fk
					REFERENCES consoles(console_id)
				CONSTRAINT items_console_id_nn
					NOT NULL,
	store_desc  VARCHAR2(4000),
	store_price VARCHAR2(10) DEFAULT '0.00'
				CONSTRAINT items_store_price_chk
					CHECK(REGEXP_LIKE(store_price,
								'([0-9]{0,10})(\.[0-9]{2})?$|^-?(100)(\.[0]{1,2})'
					)),
	quantity	NUMBER(5) DEFAULT 0
);

CREATE SEQUENCE seq_item_id START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_items_before
BEFORE INSERT OR UPDATE ON items FOR EACH ROW
	BEGIN
	IF INSERTING THEN 
		IF :NEW.item_id IS NULL THEN
			SELECT seq_item_id.nextval
			INTO   :NEW.item_id
			FROM   sys.dual;
		END IF;

		-- Check that a price has been set, if not inherit from RRP, if we specify a console and no game, 
		-- return the console price else return the game price into :NEW.store_price
		IF :NEW.store_price IS NULL OR :NEW.store_price = '0.00' THEN
			IF :NEW.game_id IS NULL AND :NEW.console_id IS NOT NULL THEN 
				:NEW.store_price := get_item_price(NULL, :NEW.console_id);				-- Return the console price
			ELSE
				:NEW.store_price := get_item_price(:NEW.game_id, NULL);					-- Return the game price
			END IF;
		END IF;

		-- Check that the store has set their own description for the game, if not
		-- then we shall just inherit the publishers description.
		IF :NEW.store_desc IS NULL THEN
			IF :NEW.game_id IS NULL AND :NEW.console_id IS NOT NULL THEN
				:NEW.store_desc := get_item_desc(NULL, :NEW.console_id);
			ELSE
				:NEW.store_desc := get_item_desc(:NEW.game_id, NULL);
			END IF;
		END IF;


		-- Provide any formatting (always remove leading/trailing whitespace)
		:NEW.store_desc  := TRIM(:NEW.store_desc);
		:NEW.store_price := TRIM(:NEW.store_price);

	END IF;
END;

/*-----------------------------------------------------------------
					  CONSOLES TABLE:
-------------------------------------------------------------------
 Contains all information on any console stored on the system, 
 stores are able to reference each console independently via its
 console_id, they are also able to set their own additional 
 description and sales price through their items table.
-------------------------------------------------------------------*/
CREATE TABLE  consoles
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
	rr_price    VARCHAR2(10) DEFAULT '0.00'
				CONSTRAINT consoles_rr_price_chk
					CHECK(REGEXP_LIKE(rr_price,
								'([0-9]{0,10})(\.[0-9]{2})?$|^-?(100)(\.[0]{1,2})'
					))
				CONSTRAINT consoles_rr_price_nn
					NOT NULL,
	description VARCHAR2(4000)
				CONSTRAINT consoles_description_nn
					NOT NULL,
	tags		VARCHAR2(500)
);

CREATE SEQUENCE seq_console_id START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_console_before
BEFORE INSERT OR UPDATE ON consoles FOR EACH ROW
	BEGIN
	IF INSERTING THEN 
		IF :NEW.console_id IS NULL THEN
			SELECT seq_console_id.nextval
			INTO   :NEW.console_id
			FROM   sys.dual;
		END IF;
	END IF;
END;

/*-----------------------------------------------------------------
					  MANUFACTURERS TABLE:
-------------------------------------------------------------------
 Contains all information on every manufacturer for each console
-------------------------------------------------------------------*/
CREATE TABLE manufacturers
(
	manufac_id	NUMBER(5)
				CONSTRAINT manufacturers_manufac_id_pk
					PRIMARY KEY
				CONSTRAINT manufacturers_manufac_id_nn
					NOT NULL,
	name        VARCHAR2(50)
				CONSTRAINT manufacturers_name_nn
					NOT NULL
);

CREATE SEQUENCE seq_manufacturer_id START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_manufacturer_before
BEFORE INSERT OR UPDATE ON manufacturers FOR EACH ROW
	BEGIN
	IF INSERTING THEN 
		IF :NEW.manufac_id IS NULL THEN
			SELECT seq_manufacturer_id.nextval
			INTO   :NEW.manufac_id
			FROM   sys.dual;
		END IF;
	END IF;
END;

/*-----------------------------------------------------------------
					   PUBLISHERS TABLE:
-------------------------------------------------------------------
 Contains all information on every publisher for each game
-------------------------------------------------------------------*/
CREATE TABLE publishers
(
	publish_id	NUMBER(5)
				CONSTRAINT publishers_publish_id_pk
					PRIMARY KEY
				CONSTRAINT publishers_publish_id_nn
					NOT NULL,
	name        VARCHAR2(50)
				CONSTRAINT publishers_name_nn
					NOT NULL
);

CREATE SEQUENCE seq_publisher_id START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_publisher_before
BEFORE INSERT OR UPDATE ON publishers FOR EACH ROW
	BEGIN
	IF INSERTING THEN 
		IF :NEW.publish_id IS NULL THEN
			SELECT seq_publisher_id.nextval
			INTO   :NEW.publish_id
			FROM   sys.dual;
		END IF;
	END IF;
END;

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
	publisher   NUMBER(5)
				CONSTRAINT games_publisher_fk
					REFERENCES publishers(publish_id)
				CONSTRAINT games_publisher_nn
					NOT NULL,
	category    VARCHAR2(100)
				CONSTRAINT games_category_chk
					CHECK
					(
						-- Avoid any case insensitivity and check category here,
						-- there arent many categories so we can remove table dependency
						UPPER(category) = 'RPG'      OR
						UPPER(category) = 'ACTION'   OR
						UPPER(category) = 'SPORT'    OR
						UPPER(category) = 'STRATEGY' OR
						UPPER(category) = 'FPS'      OR
						UPPER(category) = 'RTS'      OR
						UPPER(category) = 'MMO'      OR
						UPPER(category) = 'OTHER'
					)
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
	rr_price    VARCHAR2(10) DEFAULT '0.00'
				CONSTRAINT games_rr_price
					CHECK(REGEXP_LIKE(rr_price,
								'([0-9]{0,10})(\.[0-9]{2})?$|^-?(100)(\.[0]{1,2})'
					)),
	tags        VARCHAR2(500)				
);

CREATE SEQUENCE seq_games_id START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_games_before
BEFORE INSERT OR UPDATE ON games FOR EACH ROW
	BEGIN
	IF INSERTING THEN 
		IF :NEW.game_id IS NULL THEN
			SELECT seq_games_id.nextval
			INTO   :NEW.game_id
			FROM   sys.dual;
		END IF;
	END IF;
END;

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
CREATE TABLE store_images
(
	image_id	NUMBER(11)
				CONSTRAINT store_images_image_id_pk
					PRIMARY KEY
				CONSTRAINT store_images_image_id_nn
					NOT NULL,
	game_id		NUMBER(11)
				CONSTRAINT store_images_game_id_fk
					REFERENCES games(game_id) ON DELETE SET NULL,
	console_id  NUMBER(11)
				CONSTRAINT store_images_console_id_fk
					REFERENCES consoles(console_id) ON DELETE SET NULL,
	filename	VARCHAR(50)
				CONSTRAINT store_images_filename_nn
					NOT NULL,
	priority    VARCHAR(15)
				CONSTRAINT store_images_priority_nn
					NOT NULL
				CONSTRAINT store_images_priority_chk
					CHECK
					(	
						UPPER(priority) = 'COVER' OR 
						UPPER(priority) = 'OTHER' 
				    ),
	image 		ORDIMAGE
				CONSTRAINT store_images_image_nn 
					NOT NULL,
	thumbnail	BLOB
);

CREATE SEQUENCE seq_store_image_id START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_store_images_before
BEFORE INSERT OR UPDATE ON store_images FOR EACH ROW
	BEGIN
	IF INSERTING THEN 
		IF :NEW.image_id IS NULL THEN
			SELECT seq_store_image_id.nextval
			INTO   :NEW.image_id
			FROM   sys.dual;
		END IF;
	END IF;
END;


/*-----------------------------------------------------------------
						GET ITEM PRICE
-------------------------------------------------------------------
 Returns the price of the given game or console ID
-------------------------------------------------------------------*/
CREATE OR REPLACE FUNCTION get_item_price
(
	this_game		games.game_id%TYPE,
	this_console	consoles.console_id%TYPE
)
	RETURN STRING
IS
	this_price		STRING(50);
BEGIN
	-- Check that we have been given a console
	IF this_console IS NOT NULL THEN
		SELECT consoles.rr_price
		INTO   this_price
		FROM   consoles
		WHERE  consoles.console_id = this_console;
    -- If a console isn't specified, then check for a game
	ELSIF this_game IS NOT NULL THEN
		SELECT games.rr_price
		INTO   this_price
		FROM   games
		WHERE  games.game_id = this_game;
	END IF;

	-- Return the price string
	RETURN this_price;
END get_item_price;

/*-----------------------------------------------------------------
					GET ITEM DESCRIPTION
-------------------------------------------------------------------
 Returns the description of the given game or console ID
-------------------------------------------------------------------*/
CREATE OR REPLACE FUNCTION get_item_desc
(
	this_game		games.game_id%TYPE,
	this_console	consoles.console_id%TYPE
)
	RETURN STRING
IS
	this_desc		STRING(5000);
BEGIN
	-- Check we have been given a console
	IF this_console IS NOT NULL THEN
		SELECT  consoles.description
		INTO 	this_desc
		FROM 	consoles
		WHERE   consoles.console_id = this_console;
	-- If a console wasn't specified then check for a game
	ELSIF this_game IS NOT NULL THEN
		SELECT	games.description
		INTO 	this_desc
		FROM    games
		WHERE   games.game_id = this_game;
	END IF;

	-- Return the product description
	RETURN this_desc;
END get_item_desc;