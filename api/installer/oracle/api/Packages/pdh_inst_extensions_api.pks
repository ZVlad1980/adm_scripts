create or replace package pdh_inst_extensions_api is

  -- Author  : VZHURAVOV
  -- Created : 1/9/2019 4:30:42 PM
  -- Purpose : API of PDH Installer
  
  -- Public type declarations
  function get_extension_id(
    p_extension     pdh_inst_extensions_t.ext_code%type
  ) return pdh_inst_extensions_t.ext_id%type;
  
  function get_version(
    p_ext_id        pdh_inst_extensions_t.ext_id%type
  ) return pdh_inst_extensions_t.ext_version%type;
  
  function get_commit_sha(
    p_ext_id        pdh_inst_extensions_t.ext_id%type
  ) return pdh_inst_extensions_t.commit_sha%type;
  
  function exists_extension(
    p_extension     pdh_inst_extensions_t.ext_code%type,
    x_ext_id    out pdh_inst_extensions_t.ext_id%type
  ) return boolean;
  
  function get_extension_row(
    p_extension_id pdh_inst_extensions_t.ext_id%type
  ) return pdh_inst_extensions_t%rowtype;
  
  procedure create_extension(
    x_ext_id         out pdh_inst_extensions_t.ext_id%type,
    p_extension          pdh_inst_extensions_t.ext_code%type,
    p_version            pdh_inst_extensions_t.ext_version%type,
    p_ext_descr          pdh_inst_extensions_t.ext_descr%type,
    p_created_by         pdh_inst_extensions_t.created_by%type
  );
  
  procedure update_extension(
    p_extension_id   pdh_inst_extensions_t.ext_id%type,
    p_version        pdh_inst_extensions_t.ext_version%type,
    p_commit_sha     pdh_inst_extensions_t.commit_sha%type,
    p_ext_descr      pdh_inst_extensions_t.ext_descr%type,
    p_created_by     pdh_inst_extensions_t.created_by%type
  );
  
end pdh_inst_extensions_api;
/
