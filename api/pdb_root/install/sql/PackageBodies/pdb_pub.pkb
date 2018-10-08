create or replace package body pdb_pub is

  /**
   * ѕроцедура clone - создание клона PDB_NODE
   * 
   * p_creator     - им€ создател€
   * p_pdb_name    - им€ создаваемого клона
   * p_pdb_parent  - им€ PDB-источника
   *
   *  ≈сли p_refreshable или p_freeze отличны от дефолтных значений - событие не будет поставлено в очередь, но
   *    в таблице PDB_CLONES_T будет содана запись о новом клоне, который, в свою очередь, 
   *    будет создан при очередном обслуживании Ѕƒ
   */
  procedure clone(
    p_creator      varchar2,
    p_pdb_name     varchar2,
    p_pdb_parent   varchar2
  ) is
  begin
    clone(
      p_creator     => p_creator   ,
      p_pdb_name    => p_pdb_name  ,
      p_pdb_parent  => p_pdb_parent,
      p_refreshable => null,
      p_freeze      => null
    );
  end clone;
  
  /**
   * ѕроцедура clone - создание клона PDB_NODE
   * 
   * p_creator     - им€ создател€
   * p_pdb_name    - им€ создаваемого клона
   * p_pdb_parent  - им€ PDB-источника
   * p_refreshable - режим обновлени€ 
   * p_freeze      - заморозка клона
   *
   *  ≈сли p_refreshable или p_freeze отличны от дефолтных значений - событие не будет поставлено в очередь, но
   *    в таблице PDB_CLONES_T будет содана запись о новом клоне, который, в свою очередь, 
   *    будет создан при очередном обслуживании Ѕƒ
   */
  procedure clone(
    p_creator      varchar2,
    p_pdb_name     varchar2,
    p_pdb_parent   varchar2,
    p_refreshable  varchar2,
    p_freeze       varchar2
  ) is
  begin
    pdb_api.action(
      p_action      => pdb_api.GC_ACT_CLONE,
      p_pdb_name    => substr(upper(p_pdb_name), 1, 30),
      p_pdb_parent  => substr(upper(p_pdb_parent), 1, 30),
      p_creator     => upper(nvl(p_creator, user)),
      p_refreshable => p_refreshable,
      p_freeze      => p_freeze
    );
    commit;
  exception
    when others then
      rollback;
      raise;
  end clone;
  
  procedure open_(
    p_pdb_name varchar2
  ) is 
  begin
    pdb_api.action(
      p_action     => pdb_api.GC_ACT_OPEN,
      p_pdb_name   => p_pdb_name
    );
    commit;
  exception
    when others then
      rollback;
      raise;
  end open_;
  
  procedure open_ro_(
    p_pdb_name varchar2
  ) is 
  begin
    pdb_api.action(
      p_action     => pdb_api.GC_ACT_OPEN_RO,
      p_pdb_name   => p_pdb_name
    );
    commit;
  exception
    when others then
      rollback;
      raise;
  end open_ro_;
  
  procedure close_(
    p_pdb_name varchar2
  ) is 
  begin
    pdb_api.action(
      p_action     => pdb_api.GC_ACT_CLOSE,
      p_pdb_name   => p_pdb_name
    );
    commit;
  exception
    when others then
      rollback;
      raise;
  end close_;
  
  procedure get_clone_row(
    p_pdb_name  varchar2,
    p_clone_row in out nocopy pdb_clones_v%rowtype
  ) is
  begin
    p_clone_row.pdb_name := p_pdb_name;
    pdb_api.get_clone_row(p_clone_row);
    if p_clone_row.id is null then
      dbms_output.put_line('PDB ' || p_pdb_name || ' not found');
      raise no_data_found;
    end if;
  end get_clone_row;
  
  procedure freeze_(
    p_pdb_name varchar2
  ) is 
    l_clone_row pdb_clones_v%rowtype;
  begin
    
    get_clone_row(p_pdb_name, l_clone_row);
    
    if l_clone_row.freeze = pdb_api.GC_FRZ_NO then
      l_clone_row.freeze := pdb_api.GC_FRZ_YES;
      pdb_api.update_clone(p_clone_row => l_clone_row);
      commit;
    end if;
    
  exception
    when others then
      rollback;
      raise;
  end freeze_;
  
  procedure unfreeze_(
    p_pdb_name varchar2
  ) is
    l_clone_row pdb_clones_v%rowtype;
  begin
    
    get_clone_row(p_pdb_name, l_clone_row);
    
    if l_clone_row.freeze = pdb_api.GC_FRZ_YES then
      l_clone_row.freeze := pdb_api.GC_FRZ_NO;
      pdb_api.update_clone(p_clone_row => l_clone_row);
      commit;
    end if;
    
  exception
    when others then
      rollback;
      raise;
  end unfreeze_;
  
  /**
   * ѕроцедура set_refreshable - устанавливает режим обновлени€ клона
   * 
   * p_pdb_name - им€ PDB
   * p_refresh  - режим обновлени€, см. выше константы GC_PFR
   *
   */
  procedure set_refreshable(
    p_pdb_name varchar2,
    p_refresh  varchar2
  ) is 
    l_clone_row pdb_clones_v%rowtype;
  begin
    if p_refresh not in (GC_RFR_NO, GC_RFR_DAILY, GC_RFR_PARENT) then
      dbms_output.put_line('Ќе известный режим обновлени€: ' || p_refresh);
      raise no_data_found;
    end if;
    
    get_clone_row(p_pdb_name, l_clone_row);
    
    if l_clone_row.refreshable <> p_refresh then
      l_clone_row.refreshable := p_refresh;
      pdb_api.update_clone(p_clone_row => l_clone_row);
      commit;
    end if;
    
  exception
    when others then
      rollback;
      raise;
  end set_refreshable;
  
  /**
   * ѕроцедура request_drop пометит PDB дл€ удалени€, т.е. снимет заморозку и сделает клон не обновл€емым
   *   —амо удаление будет выполнено при обслуживании Ѕƒ
   */
  procedure request_drop(
    p_pdb_name varchar2
  ) is 
  begin
    
    unfreeze_(p_pdb_name => p_pdb_name);
    set_refreshable(p_pdb_name => p_pdb_name, p_refresh => GC_RFR_NO);
    close_(p_pdb_name => p_pdb_name);
    pdb_api.action(
      p_action      => pdb_api.GC_ACT_DROP,
      p_pdb_name    => p_pdb_name,
      p_planned_at  => trunc(sysdate) + 1.20833
    );
  exception
    when others then
      rollback;
      raise;
  end request_drop;
  
end pdb_pub;
/
