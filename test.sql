DECLARE

  l_query  VARCHAR2(4000);

BEGIN
	-- Assign values to the base query object
	l_query :=
        'SELECT 
         	stores.store_id,
         	stores.name,
         	stores.description,
         	stores.postcode,
         	COUNT(items.quantity) AS total_stock
         FROM items
         JOIN stores 
         ON stores.store_id = items.store_id
         ';
        
    -- Append to the query, only if we have a valid search string, else return
    -- all games in the table.
    IF :P1_REPORT_SEARCH IS NOT NULL THEN
        l_query := l_query || ' ' || q'{
               WHERE
               (
                   CONTAINS(description, '$}'||:P1_REPORT_SEARCH||q'{') > 0 OR
                   CONTAINS(stores.name, '$}'||:P1_REPORT_SEARCH||q'{') > 0 
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
				}';
		END IF;
			l_query := l_query || ' ' || q'{
			   GROUP BY 
	 				stores.store_id, 
	 				stores.name, 
	 				stores.description, 
	 				stores.postcode
	 		   }';
    ELSE
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
         		GROUP BY 
	 				stores.store_id, 
	 				stores.name, 
	 				stores.description, 
	 				stores.postcode
	 		   }'; 
    END IF;
RETURN l_query;
END;


SELECT DISTINCT s.store_id, s.name, s.description, s.postcode, COUNT(items.quantity) AS stock
FROM stores s
LEFT JOIN items ON s.store_id = items.store_id
WHERE  
(
  s.name = 'Game Station'
)  AND SDO_WITHIN_DISTANCE (   s.location,
   SDO_GEOMETRY(2001, 
                              8307, 
                              get_my_location('NN84SL'), 
                              null, 
                              null), 
  'distance=1000 unit=mile') = 'TRUE'
  GROUP BY s.store_id, s.name, s.description, s.postcode;

SELECT * FROM stores;
SELECT * FROM games;

SELECT * FROM stores;
SELECT name || ' - ' || postcode AS d, store_id AS r FROM stores;

SELECT DISTINCT games.title d, games.game_id r FROM items JOIN games ON items.game_id = games.game_id WHERE items.store_id = 2 ORDER BY games.title ASC;