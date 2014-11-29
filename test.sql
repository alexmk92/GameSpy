DECLARE

	l_query VARCHAR2(4000);

BEGIN

	-- Assign values to the base query
	l_query :=
	'
	SELECT 
		 items.item_id,
		 games.title AS Title,
		 consoles.name AS Platform,
		 items.store_desc AS Description,
		 items.store_price AS Price,
		 items.quantity AS Quantity
	FROM ITEMS
	JOIN games    ON items.game_id = games.game_id
	JOIN consoles ON items.console_id = consoles.console_id
	';

  	-- Append the query, only if we have a valid search string, else return all results
  	IF :P2_SEARCH_ITEM IS NOT NULL THEN 
  		l_query := l_query || ' ' || q'{
  			WHERE 
  			(
  				CONTAINS(store_desc, '$}'||:P2_SEARCH_ITEM||q'{') > 0 OR
  			)
			AND store_id = :P2_STORE_ID
			ORDER BY games.title ASC 
  		}';
  	ELSE
  		l_query := l_query || ' ' || q'{ 
  			AND store_id = :P2_STORE_ID 
  			ORDER BY games.title ASC
  		}';
  	END IF;
RETURN l_query;
END;
