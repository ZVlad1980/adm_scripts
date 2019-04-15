create or replace type tst_anchor_typ as object(
-- Author  : VZHURAVOV
-- Created : 4/8/2019 10:08:59 AM
-- Purpose : 

-- Attributes
  ver_major   int,
  ver_minor   int,
  ver_release int,

-- Member functions and procedures
  member function version return varchar2,
  not instantiable member function get_version_part(
    p_ver_type varchar2 --major/minor/release
  ) return int
)
not instantiable not final
/
