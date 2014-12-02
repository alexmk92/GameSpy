DECLARE

  l_query  VARCHAR2(4000);

BEGIN

	-- Assign values to the base query object
	l_query :=
        'SELECT DISTINCT
	        stores.store_id,
	        stores.name,
	        stores.description,
	        stores.postcode,
	        dbms_lob.getlength(store_images.thumbnail) AS thumbnail
		FROM stores
		LEFT JOIN store_images 
			ON stores.store_id = store_images.store_id
		JOIN items 
			ON stores.store_id = items.store_id
		JOIN games 
			ON items.game_id = games.game_id
		JOIN consoles
			ON items.console_id = consoles.console_id
         ';
        
    -- Append to the query, only if we have a valid search string, else return
    -- all games in the table.
    IF :P1_REPORT_SEARCH IS NOT NULL THEN
        l_query := l_query || ' ' || q'{
               WHERE
               ( 
                    CONTAINS(stores.description, '$}'||:P1_REPORT_SEARCH||q'{') > 0 OR
                    CONTAINS(stores.name, '$}'||:P1_REPORT_SEARCH||q'{') > 0 OR
                    CONTAINS(consoles.name, '$}'||:P1_REPORT_SEARCH||q'{') > 0 OR
	          		CONTAINS(consoles.tags, '$}'||:P1_REPORT_SEARCH||q'{') > 0 OR
	          		CONTAINS(games.tags, '$}'||:P1_REPORT_SEARCH||q'{') > 0 OR
	          		CONTAINS(games.title, '$}'||:P1_REPORT_SEARCH||q'{') > 0 
               )}';
				IF :P1_LOCATION IS NOT NULL THEN
					l_query := l_query || ' ' || q'{
						AND SDO_WITHIN_DISTANCE 
						(
							stores.location,
							SDO_GEOMETRY
							(
								2001,
								8307,
								get_my_location(:P1_LOCATION),
								null,
								null
							),
							'distance=&P1_RADIUS. unit=mile'
						) = 'TRUE'
						AND store_images.priority = 'COVER'
						}';
				END IF;
    ELSIF :P1_RADIUS IS NOT NULL AND :P1_LOCATION IS NOT NULL THEN
          l_query := l_query || ' ' || q'{
          		WHERE SDO_WITHIN_DISTANCE
          		(
          			stores.location,
					SDO_GEOMETRY
					(
						2001,
						8307,
						get_my_location(:P1_LOCATION),
						null,
						null
					),
					'distance=&P1_RADIUS. unit=mile'
          		) = 'TRUE'
         		AND store_images.priority = 'COVER'
         	}'; 
    ELSE
    	   l_query := l_query || ' ' || q'{
    	   		WHERE ( store_images.priority = 'COVER' )
    	   }';
    END IF;


	RETURN l_query;
END;