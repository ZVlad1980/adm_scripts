create or replace package pdh_inst_auxiliary_api is

  -- Author  : VZHURAVOV
  -- Created : 2/6/2019 3:54:45 PM
  -- Purpose : 
  
  -- Public type declarations
  type g_extension_typ is record(
    instance_name varchar2(30),
    ext_code      varchar2(100) ,
    ext_version   varchar2(20) ,
    commit_sha    varchar2(120) 
  );
  type g_extensions_typ is table of g_extension_typ;
  
  function get_extensions(
    p_db_list sys.odcivarchar2list
  ) return g_extensions_typ
  pipelined;

end pdh_inst_auxiliary_api;
/
