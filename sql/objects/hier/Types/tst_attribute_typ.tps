create or replace type tst_attribute_typ under tst_element#_typ (
  -- Author  : VZHURAVOV
  -- Created : 4/8/2019 3:10:01 PM
  -- Purpose : 
  
  -- Attributes
  value# varchar2(2000),
  -- Member functions and procedures
  constructor function tst_attribute_typ return self as result,
  constructor function tst_attribute_typ(
    p_name  varchar2,
    p_value varchar2
  ) return self as result,
  --
  member procedure value(p_value varchar2),
  member function value return varchar2,
  --
  overriding member function get_element return varchar2,
  overriding member function is_leave return varchar2
) not final
/
