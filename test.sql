-- Any test blocks for running PLSQL in SQLDEV go here


-- Test set_spatial_point function works
DECLARE
  my_object    MDSYS.SDO_GEOMETRY;  
  postcode     VARCHAR2(10);
BEGIN
  postcode := 'PL48AA';
  my_object := set_spatial_point(postcode);
  dbms_output.put_line('Results for ' || postcode || '.');
  dbms_output.put_line('sdo_x = '||my_object.sdo_point.x);
  dbms_output.put_line('sdo_y = '||my_object.sdo_point.y);
  dbms_output.put_line('sdo_z = '||my_object.sdo_point.z);
END;