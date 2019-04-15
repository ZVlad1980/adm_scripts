create or replace type tst_element_typ under tst_element#_typ (
  -- Author  : VZHURAVOV
  -- Created : 4/8/2019 2:58:41 PM
  -- Purpose : 
  -- Attributes
  attributes#  tst_attributes_typ,
  childs#      tst_elements#_typ,
  --
  constructor function tst_element_typ return self as result,
  constructor function tst_element_typ(
    p_tag        varchar2,
    p_content    tst_elements#_typ,
    p_attributes tst_attributes_typ default null
  ) return self as result,
  constructor function tst_element_typ(
    p_tag        varchar2,
    p_content    varchar2,
    p_attributes tst_attributes_typ default null
  ) return self as result,
  --
  member function attributes return varchar2,
  member function childs return varchar2,
  --
  overriding member function get_element return varchar2,
  overriding member function is_leave return varchar2
) not final
/
