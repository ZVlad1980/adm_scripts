create or replace package body pdh_inst_auxiliary_api is
  
  procedure get_extension_db(
    p_extensions in out nocopy g_extensions_typ,
    p_db_link              varchar2
  ) is
  pragma autonomous_transaction;
    type l_extensions_typ is table of pdh_inst_extensions_t%rowtype;
    l_stmt varchar2(1000);
    l_ext_cur sys_refcursor;
    
    l_ext  l_extensions_typ;
    l_pos  int;
  begin
    l_stmt := 'select * from ' || 
      case when upper(p_db_link) = 'PDH_PDEV' then 'prod_pdh.' end ||
        'pdh_inst_extensions_t' || 
      case when upper(p_db_link) not in ('PDH_DEV', 'PDH_PDEV') then '@' || p_db_link end;
    
    open l_ext_cur for l_stmt;
    fetch l_ext_cur
      bulk collect into l_ext;
    close l_ext_cur;
    
    l_pos := p_extensions.count;
    p_extensions.extend(l_ext.count);
    for i in 1..l_ext.count loop
      p_extensions(l_pos + i).instance_name := p_db_link;
      p_extensions(l_pos + i).ext_code      := l_ext(i).ext_code     ;
      p_extensions(l_pos + i).ext_version   := l_ext(i).ext_version  ;
      p_extensions(l_pos + i).commit_sha    := l_ext(i).commit_sha   ;
    end loop;
    
    if upper(p_db_link) not in ('PDH_DEV', 'PDH_PDEV') then
      rollback;
      dbms_session.close_database_link(p_db_link);
      commit;
    end if;
    
  exception
    when others then
      rollback;
      raise;
  end;

  function get_extensions(
    p_db_list sys.odcivarchar2list
  ) return g_extensions_typ
  pipelined
  is
    l_result g_extensions_typ;
  begin
    
    l_result := g_extensions_typ();
    
    for i in 1..p_db_list.count loop
      get_extension_db(l_result, p_db_list(i));
    end loop;
  
    for i in 1..l_result.count loop
      pipe row (l_result(i));
    end loop;
  end;
  
end pdh_inst_auxiliary_api;
/
