DECLARE

	l_query VARCHAR2(4000);

BEGIN

	-- Assign values to the base query
	l_query :=
	'
		SELECT DISTINCT
			items.item_id,
			items.store_desc, 
			store_images.image_id, 
			games.title,
			games.game_id, 
			dbms_lob.getlength(store_images.thumbnail) AS thumbnail
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
			ORDER BY games.title ASC 
  		}';
  	ELSE
  		l_query := l_query || ' ' || q'{ 
  			WHERE items.store_id = :P2_STORE_ID
  			AND store_images.priority = 'COVER'
  			ORDER BY items.item_id DESC
  		}';
  	END IF;
RETURN l_query;
END;