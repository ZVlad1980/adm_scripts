create or replace type tst_element#_typ under tst_anchor_typ
(
  -- Author  : VZHURAVOV
  -- Created : 4/8/2019 2:33:11 PM
  -- Purpose : 
  
  -- Attributes
  name# varchar2(50),

  -- Member functions and procedures
  member procedure name(p_name varchar2),
  member function name return varchar2,
  --
  not instantiable member function get_element return varchar2,
  not instantiable member function is_leave return varchar2,
  --
  overriding member function get_version_part(
    p_ver_type varchar2 --major/minor/release
  ) return int
  --
) not instantiable not final
/
