SELECT 
STORES.STORE_ID,
STORES.NAME,
STORES.DESCRIPTION,
STORES.POSTCODE,
dbms_lob.getlength(STORE_IMAGES.THUMBNAIL) "THUMBNAIL"
FROM  STORES
JOIN store_images ON stores.store_id = store_images.store_id
where 
(   
 instr(upper("NAME"),upper(nvl(:P1_REPORT_SEARCH,"NAME"))) > 0  or
 instr(upper("DESCRIPTION"),upper(nvl(:P1_REPORT_SEARCH,"DESCRIPTION"))) > 0  or
 instr(upper("POSTCODE"),upper(nvl(:P1_REPORT_SEARCH,"POSTCODE"))) > 0 
)