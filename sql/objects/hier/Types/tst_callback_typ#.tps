create or replace type tst_callback_typ# under tst_anchor_typ(
  -- Author  : VZHURAVOV
  -- Created : 4/8/2019 4:13:19 PM
  -- Purpose : 
  
  dummy int,
  --
  overriding member function get_version_part(
    p_ver_type varchar2 --major/minor/release
  ) return int,
  -- Attributes
  not instantiable member function callback return varchar2
) not instantiable not final
/
