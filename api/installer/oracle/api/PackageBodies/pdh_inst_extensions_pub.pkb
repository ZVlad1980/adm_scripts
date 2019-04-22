create or replace package body pdh_inst_extensions_pub is
  C_MODULE constant varchar2(30) := 'PDH_INSTALL';
  -- Private type declarations
  /**
   * This function return property of extension
   *  p_extendsion - extension's code (pdh_inst_extensions_t.ext_code)
   *  p_property   - property of extension (see constants pdh_inst_extensions_def.C_EP_)
   *
   */
  function request(
    p_extension pdh_inst_extensions_t.ext_code%type,
    p_property  varchar2
  ) return varchar2 is
    l_result varchar2(200);
    l_extension_id pdh_inst_extensions_t.ext_id%type;
  begin
    --
    if pdh_inst_extensions_api.exists_extension(p_extension => p_extension, x_ext_id => l_extension_id) then
      l_result := case p_property
        when pdh_inst_extensions_def.C_EP_VERSION then pdh_inst_extensions_api.get_version(p_ext_id => l_extension_id)
        when pdh_inst_extensions_def.C_EP_COMMIT_SHA then pdh_inst_extensions_api.get_commit_sha(p_ext_id => l_extension_id)
      end;
    end if;
    --
    return case when l_result is null and p_property = pdh_inst_extensions_def.C_EP_VERSION then '0.0.0' else l_result end;
    --
  end request;
  
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
  ) is
    l_extension_id pdh_inst_extensions_t.ext_id%type;
  begin
    --
    if not pdh_inst_extensions_api.exists_extension(p_extension => p_extension, x_ext_id => l_extension_id) then
      pdh_inst_extensions_api.create_extension(
        x_ext_id       => l_extension_id,
        p_extension    => p_extension,
        p_version      => p_version  ,
        p_ext_descr    => p_ext_descr,
        p_created_by   => sys_context( 'userenv', 'os_user' )
      );
      dbms_output.put_line('Register extension "' || p_extension || '", ext_id: ' || l_extension_id);
    else
      dbms_output.put_line('Extension "' || p_extension || '" already registered');
    end if;
    --
  end register;
  
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
  ) is
    l_extension_row pdh_inst_extensions_t%rowtype;
  begin
    --
    if pdh_inst_extensions_api.exists_extension(p_extension => p_extension, x_ext_id => l_extension_row.ext_id) then
      l_extension_row := pdh_inst_extensions_api.get_extension_row(l_extension_row.ext_id);
      pdh_inst_extensions_api.update_extension(
        p_extension_id => l_extension_row.ext_id    ,
        p_version      => p_version                 ,
        p_commit_sha   => p_commit_sha              ,
        p_ext_descr    => l_extension_row.ext_descr ,
        p_created_by   => sys_context( 'userenv', 'os_user' )
      );
    end if;
    --
  end set_version;
  
end pdh_inst_extensions_pub;
/
