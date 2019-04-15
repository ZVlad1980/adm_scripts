create or replace type tst_el_text_typ under tst_element#_typ(
  -- Author  : VZHURAVOV
  -- Created : 4/8/2019 3:50:26 PM
  -- Purpose : 
  
  -- Attributes
  content# varchar2(32767),
  --
  constructor function tst_el_text_typ return self as result,
  constructor function tst_el_text_typ(
    p_content    varchar2
  ) return self as result,
  --
  member procedure content(p_content varchar2),
  member function content return varchar2,
  -- Member functions and procedures
  overriding member function get_element return varchar2,
  overriding member function is_leave return varchar2
)
/
