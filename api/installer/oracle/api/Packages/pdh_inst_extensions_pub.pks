create or replace package pdh_inst_extensions_pub is

  -- Author  : VZHURAVOV
  -- Created : 1/9/2019 3:38:59 PM
  -- Purpose : Public API PDH Installer
  
  -- Public type declarations
  /**
   * This function return property of extension
   *  p_extendsion - extension's code (pdh_inst_extensions_t.ext_code)
   *  p_property   - property of extension (see constants pdh_inst_extensions_def.C_EP_)
   *
   */
  function request(
    p_extension pdh_inst_extensions_t.ext_code%type,
    p_property  varchar2
  ) return varchar2;
  
  /**
   * This procedure register only a new extension
   *   It'll do nothing if extension is already registered
   *
   * p_extension  - extension's code
   * p_ext_descr  - description of extension
   *
   */
  procedure register(
    p_extension   pdh_inst_extensions_t.ext_code%type,
    p_ext_descr   pdh_inst_extensions_t.ext_descr%type,
    p_version     pdh_inst_extensions_t.ext_version%type default '0.0.0'
  );
  
  /**
   * This procedure set version of exists extension,
   *  It'll do nothing if extension won't be found (not registered)
   *
   * p_extension  - extension's code
   * p_version    - version of extension (FORMAT: Major/Minor/Fix)
   * p_commit_sha - SHA of Git repository commit
   *
   */
  procedure set_version(
    p_extension   pdh_inst_extensions_t.ext_code%type,
    p_version     pdh_inst_extensions_t.ext_version%type,
    p_commit_sha  pdh_inst_extensions_t.commit_sha%type
  );
  
end pdh_inst_extensions_pub;
/
