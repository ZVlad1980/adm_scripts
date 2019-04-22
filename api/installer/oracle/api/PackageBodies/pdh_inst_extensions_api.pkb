create or replace package body pdh_inst_extensions_api is
  
  /**
   *
   */
  function get_extension_id(
    p_extension     pdh_inst_extensions_t.ext_code%type
  ) return pdh_inst_extensions_t.ext_id%type is
    l_result pdh_inst_extensions_t.ext_id%type;
  begin
    --
    select e.ext_id
    into   l_result
    from   pdh_inst_extensions_t e
    where  e.ext_code = p_extension;
    --
    return l_result;
    --
  end get_extension_id;
  
  /**
   *
   */
  function get_version(
    p_ext_id        pdh_inst_extensions_t.ext_id%type
  ) return pdh_inst_extensions_t.ext_version%type is
    l_result pdh_inst_extensions_t.ext_version%type;
  begin
    select e.ext_version
    into   l_result
    from   pdh_inst_extensions_t e
    where  e.ext_id = p_ext_id;
    --
    return l_result;
  end get_version;
  
  /**
   *
   */
  function get_commit_sha(
    p_ext_id        pdh_inst_extensions_t.ext_id%type
  ) return pdh_inst_extensions_t.commit_sha%type is
    l_result pdh_inst_extensions_t.commit_sha%type;
  begin
    --
    select e.commit_sha
    into   l_result
    from   pdh_inst_extensions_t e
    where  e.ext_id = p_ext_id;
    --
    return l_result;
  end get_commit_sha;
  
  /**
   *
   */
  function exists_extension(
    p_extension       pdh_inst_extensions_t.ext_code%type,
    x_ext_id      out pdh_inst_extensions_t.ext_id%type
  ) return boolean is
    l_result boolean;
  begin
    --
    begin
      x_ext_id := get_extension_id(
        p_extension => p_extension
      );
      l_result := true;
    exception
      when no_data_found then
        x_ext_id := null;
        l_result := false;
    end;
    --
    return l_result;
    --
  end exists_extension;
  
  function get_extension_row(
    p_extension_id pdh_inst_extensions_t.ext_id%type
  ) return pdh_inst_extensions_t%rowtype is
    l_result pdh_inst_extensions_t%rowtype;
  begin
    select *
    into   l_result
    from   pdh_inst_extensions_t e
    where  e.ext_id = p_extension_id;
    return l_result;
  end get_extension_row;
  
  /**
   *
   */
  procedure create_extension(
    x_ext_id         out pdh_inst_extensions_t.ext_id%type,
    p_extension          pdh_inst_extensions_t.ext_code%type,
    p_version            pdh_inst_extensions_t.ext_version%type,
    p_ext_descr          pdh_inst_extensions_t.ext_descr%type,
    p_created_by         pdh_inst_extensions_t.created_by%type
  ) is
  begin
    --lock_extension
    insert into pdh_inst_extensions_t(
      ext_id,
      ext_code,
      ext_version,
      ext_descr,
      created_by
    ) values(
      pdh_inst_extensions_seq.nextval,
      p_extension,
      p_version,
      p_ext_descr,
      p_created_by
    ) return ext_id into x_ext_id;
    --
  end create_extension;
  
  /**
   *
   */
  procedure update_extension(
    p_extension_id   pdh_inst_extensions_t.ext_id%type,
    p_version        pdh_inst_extensions_t.ext_version%type,
    p_commit_sha     pdh_inst_extensions_t.commit_sha%type,
    p_ext_descr      pdh_inst_extensions_t.ext_descr%type,
    p_created_by     pdh_inst_extensions_t.created_by%type
  ) is 
    l_dummy   int;
  begin
    --
    begin
      select 1
      into   l_dummy
      from   pdh_inst_extensions_t ext
      where  ext.ext_id = p_extension_id
      and    ext.ext_version = p_version
      and    ext.Commit_Sha = p_commit_sha;
      
    exception
      when no_data_found then
        insert into pdh_inst_extension_hist_t(
          hist_id,
          ext_id,
          ext_version,
          commit_sha,
          ext_created_date,
          ext_created_by,
          created_date,
          created_by
        ) select pdh_inst_extension_hist_seq.nextval,
                 ext.ext_id,
                 ext.ext_version,
                 ext.commit_sha,
                 ext.created_date,
                 ext.created_by,
                 systimestamp,
                 p_created_by
          from   pdh_inst_extensions_t ext
          where  ext.ext_id = p_extension_id
        ;
        --
        update pdh_inst_extensions_t ext
        set    ext.ext_version      = nvL(p_version, ext.ext_version),
               ext.commit_sha       = nvl(p_commit_sha, ext.commit_sha),
               ext.ext_descr        = nvl(p_ext_descr, ext.ext_descr),
               ext.last_update_date = systimestamp
        where  ext.ext_id = p_extension_id
        ;
    end;           
    --
  end update_extension;
  
  
end pdh_inst_extensions_api;
/
