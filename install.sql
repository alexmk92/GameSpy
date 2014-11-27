-- Installs all tables, triggers, sequences, indexes and other depencnies in sequence of dependency
-- to ensure all appplication components are installed sequentially without breaking.

-- Tables, in order of depencny:
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
)
/
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
)
/
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
)
/
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
	tags		VARCHAR2(500),
	cover_image INTEGER DEFAULT 0
				CONSTRAINT console_cover_image_nn
					NOT NULL,
				CONSTRAINT console_cover_image_chk
					CHECK 
					(
						cover_image = 0 OR
						cover_image = 1
					)	
)
/
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
	tags        VARCHAR2(500),
	cover_image INTEGER DEFAULT 0
				CONSTRAINT game_cover_image_nn
					NOT NULL,
				CONSTRAINT games_cover_image_chk
					CHECK 
					(
						cover_image = 0 OR
						cover_image = 1
					)			
)
/
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
	image 		ORDIMAGE
				CONSTRAINT store_images_image_nn 
					NOT NULL,
	thumbnail	BLOB
)
/
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
					REFERENCES games(game_id) ON DELETE SET NULL,
	console_id  CONSTRAINT items_console_id_fk
					REFERENCES consoles(console_id) ON DELETE SET NULL,
	store_desc  VARCHAR2(4000),
	store_price VARCHAR2(10) DEFAULT '0.00'
				CONSTRAINT items_store_price_chk
					CHECK(REGEXP_LIKE(store_price,
								'([0-9]{0,10})(\.[0-9]{2})?$|^-?(100)(\.[0]{1,2})'
					)),
	quantity	NUMBER(5) DEFAULT 0
)
/
-- Sequences
CREATE SEQUENCE seq_store_id START WITH 1 INCREMENT BY 1
/
CREATE SEQUENCE seq_item_id START WITH 1 INCREMENT BY 1
/
CREATE SEQUENCE seq_console_id START WITH 1 INCREMENT BY 1
/
CREATE SEQUENCE seq_manufacturer_id START WITH 1 INCREMENT BY 1
/
CREATE SEQUENCE seq_publisher_id START WITH 1 INCREMENT BY 1
/
CREATE SEQUENCE seq_store_image_id START WITH 1 INCREMENT BY 1
/

-- Indexes
CREATE INDEX stores_desc_ctx_idx  ON stores(description) INDEXTYPE IS ctxsys.context
/
CREATE INDEX items_desc_ctx_idx ON items(store_desc) INDEXTYPE IS ctxsys.context
/
CREATE INDEX consoles_desc_ctx_idx ON consoles(description) INDEXTYPE IS ctxsys.context
/
CREATE INDEX games_desc_ctx_idx      ON games(description) INDEXTYPE IS ctxsys.context
/
CREATE INDEX stores_location_idx  ON stores(location)    INDEXTYPE IS MDSYS.SPATIAL_INDEX
/

-- Functions and Procedures
CREATE OR REPLACE FUNCTION get_item_price
(
	this_game		games.game_id%TYPE,
	this_console	consoles.console_id%TYPE
)
	RETURN STRING
IS
	this_price		STRING(50);
BEGIN
	IF this_console IS NOT NULL THEN
		SELECT consoles.rr_price
		INTO   this_price
		FROM   consoles
		WHERE  consoles.console_id = this_console;
	ELSIF this_game IS NOT NULL THEN
		SELECT games.rr_price
		INTO   this_price
		FROM   games
		WHERE  games.game_id = this_game;
	END IF;
	RETURN this_price;
END get_item_price
/
CREATE OR REPLACE FUNCTION get_item_desc
(
	this_game		games.game_id%TYPE,
	this_console	consoles.console_id%TYPE
)
	RETURN STRING
IS
	this_desc		STRING(5000);
BEGIN
	IF this_console IS NOT NULL THEN
		SELECT  consoles.description
		INTO 	this_desc
		FROM 	consoles
		WHERE   consoles.console_id = this_console;
	ELSIF this_game IS NOT NULL THEN
		SELECT	games.description
		INTO 	this_desc
		FROM    games
		WHERE   games.game_id = this_game;
	END IF;
	RETURN this_desc;
END get_item_desc
/
CREATE OR REPLACE FUNCTION get_item_name
(
	this_game		games.game_id%TYPE,
	this_console	consoles.console_id%TYPE
)
	RETURN STRING
IS
	this_game		STRING(70);
	this_console    STRING(70);
BEGIN
	IF ((this_game IS NOT NULL) AND (this_console IS NOT NULL)) THEN
		SELECT games.name
		INTO   this_game
		FROM   games
		WHERE  games.game_id = this_game
		SELECT consoles.name
		INTO   this_console
		FROM   consoles
		WHERE  consoles.console_id = this_console
		RETURN this_game || '_' || this_console
	ELSIFIF this_console IS NOT NULL THEN
		SELECT  consoles.name
		INTO 	this_console
		FROM 	consoles
		WHERE   consoles.console_id = this_console;
		RETURN this_console;
	ELSIF (this_game IS NOT NULL) THEN
		SELECT	games.name
		INTO 	this_game
		FROM    games
		WHERE   games.game_id = this_game;
		RETURN this_game;
	END IF;
	RETURN '';
END get_item_name
/
CREATE OR REPLACE FUNCTION get_default_image
	RETURN NUMBER
IS
	default_image 	NUMBER(11);
BEGIN
	SELECT image_id
	INTO   default_image
	FROM   store_images
	WHERE  store_images.filename = 'default.jpg';
	RETURN default_image;
END get_default_image
/
CREATE OR REPLACE FUNCTION set_spatial_point
(
	p_postcode stores.postcode%TYPE
)
	RETURN MDSYS.SDO_GEOMETRY
IS
	l_lng      VARCHAR2(100);
	l_lat	   VARCHAR2(100);
	n_spatial_object MDSYS.SDO_GEOMETRY;
BEGIN
	brian.POSTCODE_TO_LAT_LNG_GM_API(p_postcode, l_lat, l_lng);
	n_spatial_object := MDSYS.SDO_GEOMETRY
	(
		2001, 
		8307,
		SDO_POINT_TYPE
		(
			l_lng,
			l_lat,
			null
		),
		null,
		null 
	);
	RETURN n_spatial_object;
END set_spatial_point
/
CREATE OR REPLACE PROCEDURE create_image_from_file
(
	p_filename	 IN VARCHAR2,
	p_priority   IN VARCHAR2,
	p_store_id   stores.store_id%TYPE,
	p_console_id consoles.console_id%TYPE,
	p_game_id    games.game_id%TYPE
)
AS 
	l_image_id	INTEGER;
	l_image 	ORDSYS.ORDImage;
	ctx 		RAW(4000);
BEGIN
	l_image_id := seq_store_image_id.nextval;
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
		l_image_id, 
		p_store_id,
		p_game_id,
		p_console_id,
		p_filename,
		p_priority,
		ORDSYS.ORDImage
		(
			'FILE',
			'ISAD330_IMAGES',
			p_filename
		)
	);
	COMMIT;
	create_blob_thumbnail(l_image_id);
END
/
GRANT EXECUTE ON create_blob_thumbnail TO APEX_PUBLIC_USER
/
CREATE OR REPLACE PROCEDURE create_blob_thumbnail
(
	p_image_id IN INTEGER 
)
IS
	l_orig		 ORDSYS.ORDImage;
	l_thumb 	 ORDSYS.ORDImage;
	l_blob_thumb BLOB;
BEGIN
	SELECT image
	INTO   l_orig
	FROM   store_images
	WHERE  image_id = p_image_id FOR UPDATE;
	l_thumb := ORDSYS.ORDImage.Init();
	dbms_lob.createTemporary(l_thumb.source.localData, true);
	ORDSYS.ORDImage.processCopy (
									l_orig,
									'maxscale = 128 128',
									l_thumb
								);
	UPDATE store_images
	SET    thumbnail = l_thumb.source.localData 
	WHERE  image_id  = p_image_id;
	dbms_lob.freeTemporary(l_thumb.source.localData);
	COMMIT;
END
/
-- Triggers
CREATE OR REPLACE TRIGGER trg_stores_before
BEFORE INSERT OR UPDATE ON stores FOR EACH ROW
	BEGIN
	IF INSERTING THEN 
		IF :NEW.store_id IS NULL THEN
			SELECT seq_store_id.nextval
			INTO   :NEW.store_id
			FROM   sys.dual;
		END IF;
	END IF;
	IF INSERTING OR UPDATING THEN
		-- Provide any formatting (always remove leading/trailing whitespace)
		:NEW.name        := TRIM(INITCAP(:NEW.name));
		:NEW.description := TRIM(:NEW.description);
		:NEW.postcode    := REPLACE(:NEW.postcode, ' ' , '');
		:NEW.postcode    := TRIM(REPLACE(UPPER(:NEW.postcode), ' ', ''));

		-- Assign the geometry object to put this store on the map!
		:NEW.location    := set_spatial_point(:NEW.postcode);

		-- Set the image for the store
		create_image_from_file(
				:NEW.name || '_image',
				'COVER',
				:NEW.store_id,
				null,
				null
		);
	END IF;
END
/
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
	IF :NEW.store_price IS NULL OR :NEW.store_price = '0.00' THEN
		IF :NEW.game_id IS NULL AND :NEW.console_id IS NOT NULL THEN 
			:NEW.store_price := get_item_price(NULL, :NEW.console_id);				
		ELSE
			:NEW.store_price := get_item_price(:NEW.game_id, NULL);					
		END IF;
	END IF;
	IF :NEW.store_desc IS NULL THEN
		IF :NEW.game_id IS NULL AND :NEW.console_id IS NOT NULL THEN
			:NEW.store_desc := get_item_desc(NULL, :NEW.console_id);
		ELSE
			:NEW.store_desc := get_item_desc(:NEW.game_id, NULL);
		END IF;
	END IF;
	:NEW.store_desc  := TRIM(:NEW.store_desc);
	:NEW.store_price := TRIM(:NEW.store_price);
	create_image_from_file(
			get_item_name(:NEW.game_id, :NEW.console_id) || '_image',
			'OTHER',
			:NEW.store_id,
			:NEW.console_id,
			:NEW.game_id
	);
END
/
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

	IF NEW.cover_image IS 1 THEN 
		create_image_from_file(
			:NEW.name || '_cover_image',
			'COVER',
			null,
			:NEW.console_id,
			null
		);
	ENDIF;
END
/
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
END
/
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
END
/
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

	IF :NEW.cover_image IS 1 THEN
		-- Create a new image for this item
		create_image_from_file(
			:NEW.name || '_cover_image',
			'COVER',
			null,
			null,
			:NEW.game_id
		);
	ENDIF;
END
/
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
