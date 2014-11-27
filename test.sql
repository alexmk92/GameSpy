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
	-- Set the image id
	l_image_id := seq_store_image_id.nextval;

	-- Insert the new values
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

	-- Create a new blob thumbnail with the new image id
	create_blob_thumbnail(l_image_id);
END;