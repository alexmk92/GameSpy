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
					)),
	location    MDSYS.SDO_GEOMETRY	
);

CREATE INDEX stores_desc_ctx_idx  ON stores(description) INDEXTYPE IS ctxsys.context;
CREATE INDEX stores_name_ctx_idx  ON stores(name) INDEXTYPE IS ctxsys.context;
CREATE INDEX stores_location_idx  ON stores(location)    INDEXTYPE IS MDSYS.SPATIAL_INDEX;

CREATE SEQUENCE seq_store_id START WITH 1 INCREMENT BY 1 NOCACHE;

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
		:NEW.postcode    := TRIM(REPLACE(UPPER(:NEW.postcode), ' ', ''));

		-- Assign the geometry object to put this store on the map!
		:NEW.location    := set_spatial_point(:NEW.postcode);
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
	store_id    NUMBER(5)
				CONSTRAINT items_store_id_fk
					REFERENCES stores(store_id)
				CONSTRAINT items_store_id_nn
					NOT NULL,
	game_id     NUMBER(5)
				CONSTRAINT items_game_id_fk
					REFERENCES games(game_id) ON DELETE SET NULL,
	console_id 	NUMBER(5)
				CONSTRAINT items_console_id_fk
					REFERENCES consoles(console_id) ON DELETE SET NULL,
	store_desc  VARCHAR2(4000),
	store_price VARCHAR2(10) DEFAULT '0.00'
				CONSTRAINT items_store_price_chk
					CHECK(REGEXP_LIKE(store_price,
								'([0-9]{0,10})(\.[0-9]{2})?$|^-?(100)(\.[0]{1,2})'
					)),
	quantity	NUMBER(5) DEFAULT 0
);

CREATE INDEX items_desc_ctx_idx ON items(store_desc) INDEXTYPE IS ctxsys.context;

CREATE SEQUENCE seq_item_id START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_items_before
BEFORE INSERT OR UPDATE ON items FOR EACH ROW
	BEGIN
	IF INSERTING THEN 
		IF :NEW.item_id IS NULL THEN
			SELECT seq_item_id.nextval
			INTO   :NEW.item_id
			FROM   sys.dual;
		END IF;
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
	prod_code   VARCHAR2(10)
				CONSTRAINT consoles_prod_code_nn
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

CREATE INDEX consoles_desc_ctx_idx ON consoles(description) INDEXTYPE IS ctxsys.context;
CREATE INDEX consoles_name_ctx_idx ON consoles(name) INDEXTYPE IS ctxsys.context;
CREATE INDEX consoles_tags_ctx_idx ON consoles(tags) INDEXTYPE IS ctxsys.context;

CREATE SEQUENCE seq_console_id START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_console_before
BEFORE INSERT OR UPDATE ON consoles FOR EACH ROW
	BEGIN
	IF INSERTING THEN 
		IF :NEW.console_id IS NULL THEN
			SELECT seq_console_id.nextval
			INTO   :NEW.console_id
			FROM   sys.dual;
		END IF;
		IF :NEW.prod_code IS NULL THEN 
			:NEW.prod_code := generate_product_code();
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

CREATE SEQUENCE seq_manufacturer_id START WITH 1 INCREMENT BY 1 NOCACHE;

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

CREATE SEQUENCE seq_publisher_id START WITH 1 INCREMENT BY 1 NOCACHE;

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
	prod_code   VARCHAR2(10)
			CONSTRAINT games_prod_code_nn
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
	title		VARCHAR2(200)
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
	tags        VARCHAR2(500), 
	rating		VARCHAR2(4)
				CONSTRAINT games_rating_nn
					NOT NULL
);

CREATE INDEX games_desc_ctx_idx ON games(description) INDEXTYPE IS ctxsys.context;
CREATE INDEX games_title_ctx_idx ON games(title) INDEXTYPE IS ctxsys.context;
CREATE INDEX games_tags_ctx_idx ON games(tags) INDEXTYPE IS ctxsys.context;

CREATE SEQUENCE seq_games_id START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_games_before
BEFORE INSERT OR UPDATE ON games FOR EACH ROW
	BEGIN
	IF INSERTING THEN 
		IF :NEW.game_id IS NULL THEN
			SELECT seq_games_id.nextval
			INTO   :NEW.game_id
			FROM   sys.dual;
		END IF;
		IF :NEW.prod_code IS NULL THEN 
			:NEW.prod_code := generate_product_code();
		END IF;
	END IF;

	-- Format the category
	:NEW.category := TRIM(UPPER(:NEW.category));

	-- Check for a valid rating
	IF :NEW.rating IS NULL THEN 
		:NEW.rating := '0.0';
	ELSE
		:NEW.rating := check_valid_rating(:NEW.rating);
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
	store_id    NUMBER(11)
				CONSTRAINT store_images_store_id_fk
					REFERENCES stores(store_id) ON DELETE SET NULL,
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
	image 		ORDSYS.ORDIMAGE
				CONSTRAINT store_images_image_nn 
					NOT NULL,
	thumbnail	BLOB
);

CREATE SEQUENCE seq_store_image_id START WITH 1 INCREMENT BY 1 NOCACHE;

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
					CREATE PRODUCT CODE
-------------------------------------------------------------------
 Generates and returns a new product code
-------------------------------------------------------------------*/
CREATE OR REPLACE FUNCTION generate_product_code
	RETURN STRING
IS 
	new_code	STRING(10);
BEGIN
	-- Get the new code
	SELECT DBMS_RANDOM.STRING('X', 10)
	INTO   new_code
	FROM   sys.dual;

	-- Return the new code
	RETURN new_code;
END generate_product_code;


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

/*-----------------------------------------------------------------
					GET ITEM NAME
-------------------------------------------------------------------
 Returns the name of the console or game
-------------------------------------------------------------------*/
CREATE OR REPLACE FUNCTION get_item_name
(
	this_game		games.game_id%TYPE,
	this_console	consoles.console_id%TYPE
)
	RETURN STRING
IS
	r_this_game		  STRING(70);
	r_this_console    STRING(70);
BEGIN

	-- We have a game with a specified platform, return the formatted string
	IF this_game IS NOT NULL AND this_console IS NOT NULL THEN
		SELECT games.title
		INTO   r_this_game
		FROM   games
		WHERE  games.game_id = this_game;

		SELECT consoles.name
		INTO   r_this_console
		FROM   consoles
		WHERE  consoles.console_id = this_console;

		-- Return a formatted game string with its associated platform
		RETURN r_this_game || '_' || r_this_console;

	-- Check we have been given a console
	ELSIF this_console IS NOT NULL THEN
		SELECT  consoles.name
		INTO 	r_this_console
		FROM 	consoles
		WHERE   consoles.console_id = this_console;

		-- Return a console string
		RETURN r_this_console;

	-- If a console wasn't specified then check for a game, games are specified by a GAME or GAME and CONSOLE
	ELSIF this_game IS NOT NULL THEN
		SELECT	games.title
		INTO 	r_this_game
		FROM    games
		WHERE   games.game_id = this_game;

		-- Return a game string
		RETURN r_this_game;
	END IF;

	-- Return a blank string if all fall through (there was an error)
	RETURN '';
END get_item_name;

/*-----------------------------------------------------------------
					   GET DEFAULT IMAGE
-------------------------------------------------------------------
 Returns the Foreign Key reference of the default image in the
 store_images table
-------------------------------------------------------------------*/
CREATE OR REPLACE FUNCTION get_default_image
	RETURN NUMBER
IS
	default_image 	NUMBER(11);
BEGIN
	-- Select the default value into the return value
	SELECT image_id
	INTO   default_image
	FROM   store_images
	WHERE  store_images.filename = 'default.jpg';

	-- Return the default value
	RETURN default_image;
END get_default_image;

/*-----------------------------------------------------------------
					SET SPATIAL DATA POINT
-------------------------------------------------------------------
 Returns a spatial object from the given postcode, using the GM API,
 this will return only a long/lat POINT as we are adding it to the
 map, instead of querying surrounding points

 ** DEV NOTES ON GTYPE **
 -------------------------------------------------------------------
 --  D = 2D, 3D or 4D 
 --  L = Linear reference for 3/4D objects (0 for 2D)
 -- TT = geom type 00 - 09 where 00 = unknown, 01 = 1 point, 02 = line/curve, 03 = polygon/surface, 04 = collection, 05 = multipoint, 06 = multiline/multicurve, 07 = multipolygon or multisurface, 08 = solid, 09 = multisolid
-------------------------------------------------------------------*/
CREATE OR REPLACE FUNCTION set_spatial_point
(
	p_postcode stores.postcode%TYPE
)
	RETURN MDSYS.SDO_GEOMETRY
IS
	-- Build local variables
	l_lng      VARCHAR2(100);
	l_lat	   VARCHAR2(100);
	n_spatial_object MDSYS.SDO_GEOMETRY;
BEGIN
	-- Use Brians procedure to populate long and lat parameters
	brian.POSTCODE_TO_LAT_LNG_GM_API(p_postcode, l_lat, l_lng);

	-- Populate the new spatial object
	n_spatial_object := MDSYS.SDO_GEOMETRY
	(
		-- use 01 as we wish to add the point to the map
		2001, 
		-- SRID for WGS84 longitutde/latitude format
		8307,
		-- Set the information of the point ( we don't need a Z co-ord )
		SDO_POINT_TYPE
		(
			l_lng,
			l_lat,
			null
		),
		null,	-- We have no SDO_ELEM_INFO_ARRAY
		null 	-- We have no SDO_ORDINATE_ARRAY
	);

	-- Return the new spatial object
	RETURN n_spatial_object;
END set_spatial_point;

/*-----------------------------------------------------------------
					 GET USERS LOCATION
-------------------------------------------------------------------
 Returns the users location, we can then do proximity searching and
 all other types of searching
-------------------------------------------------------------------*/
CREATE OR REPLACE FUNCTION get_my_location
(
	p_postcode       VARCHAR2
) 
	RETURN MDSYS.SDO_POINT_TYPE
IS
	-- Local variables
	l_lng 	          VARCHAR2(100);
	l_lat	          VARCHAR2(100);
	r_my_location     MDSYS.SDO_POINT_TYPE;
BEGIN
	-- Use Brians procedure to populate long and lat parameters
	brian.POSTCODE_TO_LAT_LNG_GM_API(p_postcode, l_lat, l_lng);

	-- Populate the return object
	IF l_lat IS NOT NULL AND l_lng IS NOT NULL THEN
		r_my_location := MDSYS.SDO_POINT_TYPE(l_lng, l_lat, null);
	ELSE
		-- Invalid postcode, return a null point
		r_my_location := MDSYS.SDO_POINT_TYPE(0, 0, null);
	END IF;

	-- Return the location object
	RETURN r_my_location;
END get_my_location;

/*-----------------------------------------------------------------
					   GET AVERAGE COLOR
-------------------------------------------------------------------
 Returns the average color of an image
-------------------------------------------------------------------*/
CREATE OR REPLACE FUNCTION get_average_color_score
(
	p_input_color		VARCHAR2,
	p_input_image		store_images.image_id%TYPE
) 
	RETURN DOUBLE PRECISION
IS
	-- Local variables
	l_average_color		ORDSYS.SI_AverageColor;	
	l_image_to_eval		ORDSYS.SI_StillImage;
	l_input_color       ORDSYS.SI_Color;
	l_blob_reference 	BLOB;
	l_hex_color         VARCHAR2(6);
	l_red				NUMBER;
	l_green				NUMBER;
	l_blue              NUMBER;

	-- Determines how well the image matches the given color (%)
	r_avg_score			DOUBLE PRECISION;
BEGIN
    -- Strip the # from the input color
    l_hex_color := TRIM(REPLACE(p_input_color, '#', ''));

	-- Convert the hex value to RGB
	SELECT TO_NUMBER(substr(l_hex_color, 1, 2), 'XX') INTO l_red   FROM SYS.DUAL;
	SELECT TO_NUMBER(substr(l_hex_color, 3, 2), 'XX') INTO l_green FROM SYS.DUAL;
	SELECT TO_NUMBER(substr(l_hex_color, 5, 2), 'XX') INTO l_blue  FROM SYS.DUAL;

	-- select the thumbnail into the BLOB data column
	SELECT thumbnail 
	INTO   l_blob_reference
	FROM   store_images
	WHERE  image_id = p_input_image;

	-- Build the SI_Color Object
	l_input_color := SI_Color(l_red, l_green, l_blue);

	-- Create the SI_StillImage to evaluate 
	l_image_to_eval := new SI_StillImage(l_blob_reference);

	-- Get the average color score %
	l_average_color := NEW SI_AverageColor(l_input_color);
	r_avg_score := SI_ScoreByAvgClr(l_average_color, l_image_to_eval);

	-- Return the % score
	RETURN r_avg_score;
END get_average_color_score;

/*-----------------------------------------------------------------
					Extract distance
-------------------------------------------------------------------
 Upload a new file to the database
-------------------------------------------------------------------*/
CREATE OR REPLACE FUNCTION extract_distance
(
    p_search_string   VARCHAR2
)
    RETURN VARCHAR2
IS
    l_distance        VARCHAR2(100);
BEGIN

    -- Find a matching MILES value
    SELECT REGEXP_REPLACE(p_search_string, '^.*?(\d+ ?MILES).*$', '\1', 1, 0, 'i') INTO l_distance FROM SYS.DUAL;
    
    -- Format the string to be upper trim whitespace / strip MILES from the tag
    l_distance := UPPER(l_distance);
    l_distance := TRIM(REPLACE(l_distance, 'MILES', ''));
   
   -- Return the distance
    RETURN TRIM(l_distance);
END extract_distance;


/*-----------------------------------------------------------------
					 CHECK NUMBER METHOD
-------------------------------------------------------------------
 Upload a new file to the database
-------------------------------------------------------------------*/
CREATE OR REPLACE FUNCTION check_valid_rating
(
	p_rating games.rating%TYPE
)
	RETURN VARCHAR2
IS
	l_rating	VARCHAR2(4);
BEGIN
	-- Default return string
	l_rating := '0.0';

	-- Check for a match and return the input string if correct
	IF REGEXP_LIKE(p_rating, '^([0-9]{1})(\.[0-9]{0,1})?$') THEN
	  l_rating := p_rating;
	  RETURN l_rating;
	-- Return default
	ELSE 
	  RETURN l_rating;
	END IF;

END check_valid_rating;

/*-----------------------------------------------------------------
					 CHECK POSTCODE METHOD
-------------------------------------------------------------------
 checks postcode
-------------------------------------------------------------------*/
CREATE OR REPLACE FUNCTION check_valid_postcode
(
	p_postcode stores.postcode%TYPE
)
	RETURN VARCHAR2
IS
	r_postcode	VARCHAR2(10);
BEGIN
	-- Default return string - the university
	r_postcode := 'FALSE';

	-- Check for a match and return the input string if correct
	IF REGEXP_LIKE(UPPER(p_postcode),
	'([A-PR-UWYZ0-9][A-HK-Y0-9][AEHMNPRTVXY0-9]?[ABEHMNPRVWXY0-9]{1,2}[0-9][ABD-HJLN-UW-Z]{2}|GIR 0AA)'
	) THEN
		r_postcode := 'TRUE';
		RETURN r_postcode;
	ELSE
		RETURN 'FALSE';
	END IF;
END check_valid_postcode;

/*-----------------------------------------------------------------
					 CREATE IMAGE FROM FILE
-------------------------------------------------------------------
 Upload a new file to the database
-------------------------------------------------------------------*/
GRANT EXECUTE ON upload_image TO APEX_PUBLIC_USER 
CREATE OR REPLACE PROCEDURE upload_image
(
	p_filename	 IN VARCHAR2,
	p_priority   IN VARCHAR2,
	p_store_id   stores.store_id%TYPE,
	p_console_id consoles.console_id%TYPE,
	p_game_id    games.game_id%TYPE
)
AS 
	l_upload_size INTEGER;
	l_upload_blob BLOB;
	l_image_id	  INTEGER;
	l_image 	  ORDSYS.ORDImage;
BEGIN

	-- Get the length, MIME type and the BLOB of the new image from the upload table 
	-- apex_application_files is a synonym for WWV_FLOW_FILES
	SELECT  doc_size,
			blob_content
	INTO    l_upload_size,
			l_upload_blob
	FROM 	apex_application_files
	WHERE   name = p_filename;

	-- Insert the new row into table, initialising the new image and returning the new allocated image_id
	-- into the l_image_id for later use, the image is later set with an update
	INSERT INTO store_images
	(
		image_id,
		store_id,
		game_id,
		console_id,
		filename,
		priority,
		image
	)
	VALUES 
	(
		seq_store_image_id.nextval, 
		p_store_id,
		p_game_id,
		p_console_id,
		p_filename,
		p_priority,
		ORDSYS.ORDImage()
	)
	RETURNING image_id
	INTO l_image_id;

	-- Lock the row
	SELECT image
	INTO   l_image
	FROM   store_images
	WHERE  image_id = l_image_id
	FOR UPDATE;

	-- Copy the blobk into the ORDImage BLOB container
	DBMS_LOB.copy( l_image.source.localData, l_upload_blob, l_upload_size );
	l_image.setProperties();

	-- Update the store images table with the newly created image
	UPDATE store_images
	SET image = l_image
	WHERE image_id = l_image_id;

	-- Clear the file from the upload table
	DELETE FROM apex_application_files
	WHERE name = p_filename;

	-- Release lock and commit changes.
	COMMIT;

	-- Create thumbnail
	create_blob_thumbnail(l_image_id);

	-- Exception handler for locks
	EXCEPTION 
	WHEN others
	THEN htp.p(SQLERRM);
END upload_image;

/*-----------------------------------------------------------------
					   CREATE THUMBNAIL
-------------------------------------------------------------------
 Text search for the games table
-------------------------------------------------------------------*/
GRANT EXECUTE ON create_blob_thumbnail TO APEX_PUBLIC_USER;
CREATE OR REPLACE PROCEDURE create_blob_thumbnail
(
	p_image_id IN INTEGER 
)
IS
	l_orig		 ORDSYS.ORDImage;
	l_thumb 	 ORDSYS.ORDImage;
	l_blob_thumb BLOB;
BEGIN
	-- acquire lock on row
	SELECT image
	INTO   l_orig
	FROM   store_images
	WHERE  image_id = p_image_id FOR UPDATE;

	-- Create a new ORDImage object
	l_thumb := ORDSYS.ORDImage.Init();

	-- Copy the original image into the newly initiated thumbnail with a the 128x128 size
	dbms_lob.createTemporary(l_thumb.source.localData, true);
	ORDSYS.ORDImage.processCopy (
									l_orig,
									'maxscale = 128 128',
									l_thumb
								);

	-- Extract BLOB data from the newly populated thumbnail of type ORDImage
	UPDATE store_images
	SET    thumbnail = l_thumb.source.localData 
	WHERE  image_id  = p_image_id;

	-- Empty the temporary object and commit the transaction (clean up)
	dbms_lob.freeTemporary(l_thumb.source.localData);

	COMMIT;

	-- Exception handler for locks
	EXCEPTION 
	WHEN others
	THEN htp.p(SQLERRM);
END;

