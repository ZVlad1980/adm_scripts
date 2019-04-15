PL/SQL Developer Test script 3.0
21
-- Created on 4/8/2019 by VZHURAVOV 
declare 
  -- Local variables here
  o tst_element_typ;
begin
  -- Test statements here
  o := tst_element_typ(
    p_tag        => 'div',
    p_attributes => tst_attributes_typ(
      tst_attribute_typ('id','1'),
      tst_attribute_typ('class', 'bdy')
    ),
    p_content    => tst_elements#_typ(
      tst_element_typ(
        p_tag     => 'b',
        p_content => 'TEST SUCCESSFUL'
      )
    )
  );
  dbms_output.put_line(o.get_element());
end;
0
0
