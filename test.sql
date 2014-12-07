DECLARE

	l_query          VARCHAR2(4000);
	l_orientation    CHAR(1) := :P2_ORIENTATION;
	l_color_search   CHAR(1) := :P2_COLOR;
	l_search_term    VARCHAR(200);
	l_search_value   NUMBER(4);
	l_search_by_term CHAR(1) := 'F';

BEGIN

    IF l_color_search = 'Y' THEN
    	l_query :=
    	q'{
			  SELECT 
					items.store_desc, 
					store_images.image_id, 
					games.title,
					consoles.name,
					dbms_lob.getlength(store_images.thumbnail) AS thumbnail,
					get_average_color_score(:P2_AVERAGE_COLOR, store_images.image_id) as stock,
					items.store_price
			  FROM items
			  JOIN store_images 
			  	ON store_images.game_id = items.game_id
			  JOIN games 
			  	ON items.game_id = games.game_id
			  JOIN consoles 
			  	ON items.console_id = consoles.console_id
		}';

		-- Append the query, only if we have a valid search string, else return all results
	  	IF :P2_SEARCH_ITEM IS NOT NULL THEN
	  		l_query := l_query || ' ' || q'{
	  			WHERE 
	  			(
	  				CONTAINS(store_desc, '$}'||:P2_SEARCH_ITEM||q'{') > 0 OR
	  				CONTAINS(consoles.name, '$}'||:P2_SEARCH_ITEM||q'{') > 0 OR
	          		CONTAINS(consoles.tags, '$}'||:P2_SEARCH_ITEM||q'{') > 0 OR
	          		CONTAINS(games.tags, '$}'||:P2_SEARCH_ITEM||q'{') > 0 OR
	          		CONTAINS(games.title, '$}'||:P2_SEARCH_ITEM||q'{') > 0 OR
	          		items.store_price  >= :P2_SEARCH_ITEM 
	  			)
				AND items.store_id = :P2_STORE_ID
				AND store_images.priority = 'COVER'
				AND items.quantity > 0
				ORDER BY stock DESC
	  		}';
	  	ELSE
	  		l_query := l_query || ' ' || q'{ 
	  			WHERE items.store_id = :P2_STORE_ID
	  			AND store_images.priority = 'COVER'
	  			AND items.quantity > 0
	  			ORDER BY stock DESC
	  		}';
	  	END IF;
    ELSE
		-- Assign values to the base query
		l_query :=
		'
			SELECT DISTINCT
				items.store_desc, 
				store_images.image_id, 
				games.title,
				consoles.name,
				dbms_lob.getlength(store_images.thumbnail) AS thumbnail,
	            items.quantity AS stock,
	            items.store_price
			FROM items 
			JOIN store_images 
				ON items.game_id = store_images.game_id 
			JOIN games 
				ON items.game_id = games.game_id
			JOIN consoles
				ON items.console_id = consoles.console_id
		';

	  	-- Append the query, only if we have a valid search string, else return all results
	  	IF :P2_SEARCH_ITEM IS NOT NULL THEN
			-- Assign the search term - case insensitive
	  		l_search_term := TRIM(UPPER(:P2_SEARCH_ITEM));

	  		-- Check for a specific term of games more than
	  		IF INSTR(l_search_term, 'GAMES MORE THAN') <> 0 OR INSTR(l_search_term, 'MORE THAN') <> 0 THEN
			    
			    l_search_by_term := 'T';

			    -- Format the string so we just have the number
			    l_search_term := REPLACE(l_search_term, 'GAMES MORE THAN', '');
			    l_search_term := REPLACE(l_search_term, 'MORE THAN', '');
			    l_search_term := REPLACE(l_search_term, '£', '');
			    l_search_term := REPLACE(l_search_term, ' ', '');

			    -- Search term is now a number, strip it out.
			    l_search_value := l_search_term;

			    -- Set the evaluation
			    :P2_EVALUATION := l_search_value;

			    -- Do the search
				l_query := l_query || ' ' || q'{
		  			WHERE items.store_price >= :P2_EVALUATION
					AND items.store_id = :P2_STORE_ID
					AND store_images.priority = 'COVER'
					AND items.quantity > 0
		  		}';			    

	  		-- Check for a specific term of games less than
	  		ELSIF INSTR(l_search_term, 'GAMES LESS THAN') <> 0 OR INSTR(l_search_term, 'LESS THAN') <> 0 THEN
			   
	  			l_search_by_term := 'T';

			   -- Format the string so we just have the number
			    l_search_term := REPLACE(l_search_term, 'GAMES LESS THAN', '');
			    l_search_term := REPLACE(l_search_term, 'LESS THAN', '');
			    l_search_term := REPLACE(l_search_term, '£', '');
			    l_search_term := REPLACE(l_search_term, ' ', '');

			    -- Search term is now a number, strip it out.
			    l_search_value := l_search_term;

			    -- Set the evaluation
			    :P2_EVALUATION := l_search_value;

			    -- Do the search
				l_query := l_query || ' ' || q'{
		  			WHERE items.store_price < :P2_EVALUATION
					AND items.store_id = :P2_STORE_ID
					AND store_images.priority = 'COVER'
					AND items.quantity > 0
		  		}';

	  		-- Check for other terms with CONTAINS
	  		ELSE
		  		l_query := l_query || ' ' || q'{
		  			WHERE 
		  			(
		  				CONTAINS(store_desc, '$}'||:P2_SEARCH_ITEM||q'{') > 0 OR
		  				CONTAINS(consoles.name, '$}'||:P2_SEARCH_ITEM||q'{') > 0 OR
		          		CONTAINS(consoles.tags, '$}'||:P2_SEARCH_ITEM||q'{') > 0 OR
		          		CONTAINS(games.tags, '$}'||:P2_SEARCH_ITEM||q'{') > 0 OR
		          		CONTAINS(games.title, '$}'||:P2_SEARCH_ITEM||q'{') > 0 OR
		          		items.store_price  >= :P2_SEARCH_ITEM 
		  			)
					AND items.store_id = :P2_STORE_ID
					AND store_images.priority = 'COVER'
					AND items.quantity > 0
		  		}';
		  	END IF;
	  	ELSE
	  		l_query := l_query || ' ' || q'{ 
	  			WHERE items.store_id = :P2_STORE_ID
	  			AND store_images.priority = 'COVER'
	  			AND items.quantity > 0
	  		}';
	  	END IF;

	  	-- Add the oritentation logic
	  	IF l_orientation <> 'A' THEN
	  		IF l_orientation = 'L' THEN
	  			l_query := l_query || ' ' || q'{
	  				AND store_images.image.getWidth() > store_images.image.getHeight()
	  			}';
	  		ELSIF l_orientation = 'P' THEN
	  			l_query := l_query || ' ' || q'{
	  				AND store_images.image.getWidth() < store_images.image.getHeight()
	  			}';
	  		END IF;
	  	END IF;

	  	-- Set the order by statement
	  	IF l_search_by_term <> 'T' THEN
	  		l_query := l_query || ' ' || 'ORDER BY games.title DESC';
	  	ELSE
	  		l_query := l_query || ' ' || 'ORDER BY items.store_price DESC';
	  	END IF;
	END IF;
RETURN l_query;
END;