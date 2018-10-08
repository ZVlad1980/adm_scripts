create or replace package body pdb_api is
  
  GC_UNIT_NAME   constant varchar2(32) := $$PLSQL_UNIT;
  
  GC_PDB_OPEN       constant varchar2(15) := 'READ WRITE';
  GC_PDB_CLOSE      constant varchar2(15) := 'MOUNTED';
  GC_PDB_READ_ONLY  constant varchar2(15) := 'READ ONLY';
  GC_PDB_NOT_EXISTS constant varchar2(15) := 'NOT EXISTS';
  GC_PDB_CREATION   constant varchar2(15) := 'CREATION';
  
  --GC_ACT_REFRESH      constant varchar2(32) := 'REFRESH';
  
  G_GLOBAL_REFRESH    boolean;
--  G_PDBS_PATH         varchar2(1024);
  G_PDB_DEFAULT       varchar2(30);
  
  type g_error_rec_typ is record (
    exists            int,
    error_msg         varchar2(4000),
    critical          boolean,
    error_stack       varchar2(2000),
    error_backtrace   varchar2(2000),
    call_stack        varchar2(2000)
  );
  g_error g_error_rec_typ;
  
  procedure put_log(
    p_msg   varchar2 default null,
    p_error g_error_rec_typ default null
  ) is
    pragma autonomous_transaction;
    l_error varchar2(4000);
    procedure append_error_(p_name varchar2, p_msg varchar2) is
    begin
      l_error := l_error || case when l_error is not null then chr(10) end
        || p_name || ': ' || substr(p_msg, 1, 1000) || chr(10);
    end;
  begin
    
    if p_error.exists is not null then
      append_error_('Error msg', p_error.error_msg);
      append_error_('Error stack', p_error.error_stack);
      append_error_('Error backtrace', p_error.error_backtrace);
      append_error_('Call stack', p_error.call_stack);
    end if;
    
    insert into pdb_daemon_log_v(
      message,
      error
    ) values (
      GC_UNIT_NAME || ': ' || nvl(p_msg, p_error.error_msg),
      l_error
    );
    
    commit;
    
    dbms_output.put_line(p_msg);
    
    if l_error is not null then
      dbms_output.put_line(l_error);
    end if;

  exception
    when others then
      rollback;
  end put_log;
  
  procedure fix_exception(
    p_line int,
    p_msg  varchar2 default null,
    p_critical boolean default false
  ) is
    l_error g_error_rec_typ;
  begin
    
    l_error.exists          := 1;
    l_error.error_msg       := GC_UNIT_NAME || '(' || p_line || '): ' || nvl(p_msg, sqlerrm);
    l_error.critical        := p_critical;
    l_error.error_stack     := dbms_utility.format_error_stack;
    l_error.error_backtrace := dbms_utility.format_error_backtrace;
    l_error.call_stack      := dbms_utility.format_call_stack;
    
    put_log(p_error => l_error);
    
    if g_error.exists is null then
      g_error.exists          := 1;
      g_error.error_msg       := l_error.error_msg      ;
      g_error.critical        := l_error.critical       ;
      g_error.error_stack     := l_error.error_stack    ;
      g_error.error_backtrace := l_error.error_backtrace;
      g_error.call_stack      := l_error.call_stack     ;
    end if;
    
  end fix_exception;
  
  function get_error_msg return varchar2 is
  begin
    return case when g_error.exists is null then null else g_error.error_msg end;
  end get_error_msg;
  
  function is_critical_error return boolean is
  begin
    return case when g_error.exists is null then false else g_error.critical end;
  end is_critical_error;
  
  procedure purge_error is
  begin
    g_error.exists := null;
  end purge_error;
  
  
  procedure init$ is
  begin
    begin
      select c.pdb_name
      into   G_PDB_DEFAULT
      from   pdb_clones_v c
      where  1=1
      and    c.default_parent = 'YES';
    exception
      when no_data_found then
        null;
    end;
    
    G_GLOBAL_REFRESH := false;
    
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'PDB_API.init$ failed'); --не повод стопитьс€
      purge_error;
  end init$;
  
  procedure set_global_refresh is begin G_GLOBAL_REFRESH := true; end;
  procedure unset_global_refresh is begin G_GLOBAL_REFRESH := false; end;
  function get_global_refresh return boolean is begin return G_GLOBAL_REFRESH; end;
  
  procedure insert_clone_row(
    p_clone_row in out nocopy pdb_clones_v%rowtype
  ) is
  begin
    
    insert into pdb_clones_v(
      pdb_name,
      pdb_parent,
      open_mode,
      refreshable,
      freeze,
      creator,
      thin_clone,
      acfs_path
    ) values (
      p_clone_row.pdb_name,
      p_clone_row.pdb_parent,
      p_clone_row.open_mode,
      p_clone_row.refreshable,
      p_clone_row.freeze,
      p_clone_row.creator,
      nvl(p_clone_row.thin_clone, 'NO'),
      p_clone_row.acfs_path
    ) returning id into p_clone_row.id;
    
  end insert_clone_row;
  
  procedure update_clone(
    p_clone_row pdb_clones_v%rowtype
  ) is
  begin
    update pdb_clones_v c
    set    c.refreshable = p_clone_row.refreshable,
           c.freeze      = p_clone_row.freeze,
           c.updated_at  = current_timestamp
    where  c.id = p_clone_row.id;
    put_log('update_clone ' || p_clone_row.pdb_name || ' (' || p_clone_row.id || ').' ||
      'Refreshable: ' || p_clone_row.refreshable || ', Freeze: ' || p_clone_row.freeze
    );
  end update_clone;
  
  procedure insert_action_row(
    p_action_row pdb_actions_v%rowtype
  ) is
  begin
    insert into pdb_actions_v(
      action,
      pdb_name,
      pdb_parent,
      planned_at,
      pdb_path,
      status
    ) values (
      p_action_row.action,
      p_action_row.pdb_name,
      p_action_row.pdb_parent,
      p_action_row.planned_at,
      p_action_row.pdb_path,
      p_action_row.status
    );
  exception
    when others then
      fix_exception('insert_action_row(' || p_action_row.action || ', ' || p_action_row.pdb_name || ', ' || p_action_row.pdb_parent || ', ' || p_action_row.status || '):');
      raise;
  end insert_action_row;
  
  -- Private type declarations
  procedure create_action(
    p_action     varchar2,
    p_pdb_name   varchar2,
    p_planned_at date,
    p_pdb_path   varchar2,
    p_pdb_parent varchar2 default null
  ) is
    --
    l_action_row pdb_actions_v%rowtype;
    --
  begin
    --
    l_action_row.action     := p_action;
    l_action_row.pdb_name   := upper(p_pdb_name)  ;
    l_action_row.pdb_parent := upper(p_pdb_parent);
    l_action_row.pdb_path   := p_pdb_path;
    l_action_row.planned_at := nvl(p_planned_at, sysdate);
    l_action_row.status     := 'NEW';
    --
    insert_action_row(l_action_row);
    --
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'create_action(' || p_pdb_name || ', ' || p_pdb_parent || ')');
      raise;
  end create_action;
  
  procedure get_clone_row(
    p_clone_row in out nocopy pdb_clones_v%rowtype
  ) is
  begin
    --
    p_clone_row.pdb_name := upper(p_clone_row.pdb_name);
    --
    begin
      select *
      into   p_clone_row
      from   pdb_clones_v c
      where  c.pdb_name = nvl(p_clone_row.pdb_name, c.pdb_name)
      and    c.id = nvl(p_clone_row.id, c.id);
    exception
      when no_data_found then
        p_clone_row.id := null;
    end;
    --
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'get_clone_row(' || p_clone_row.id || ', ' || p_clone_row.pdb_name || ')');
      raise;
  end get_clone_row;
  
  procedure check_action(
    p_clone_row    in out nocopy pdb_clones_v%rowtype,
    p_action       varchar2
  ) is
    l_clone_row    pdb_clones_v%rowtype;
  begin
    --
    if p_action not in (
        GC_ACT_CLONE  ,
        GC_ACT_CLOSE  ,
        GC_ACT_OPEN   ,
        GC_ACT_OPEN_RO,
        GC_ACT_DROP   
      ) then
      fix_exception($$PLSQL_LINE, 'Reject action ' || p_action || ': unknown action.');
      raise e_action_rejected;
    end if;
    --
    if p_action = GC_ACT_CLONE then
      --
      if p_clone_row.id is not null and p_clone_row.open_mode in (
          GC_PDB_OPEN     ,
          GC_PDB_CLOSE    ,
          GC_PDB_READ_ONLY
        ) then
        fix_exception($$PLSQL_LINE, 'Reject action ' || p_action || ': clone already exists.');
        raise e_action_rejected;
      end if;
      --
      --p_clone_row.pdb_parent := nvl(p_clone_row.pdb_parent, G_PDB_DEFAULT);
      if p_clone_row.pdb_parent is null then
        fix_exception($$PLSQL_LINE, 'Reject action ' || p_action || ': parent PDB is empty.');
        raise e_action_rejected;
      end if;
      --
      l_clone_row.pdb_name := p_clone_row.pdb_parent;
      get_clone_row(
        p_clone_row => l_clone_row
      );
      --
      if not get_global_refresh then
        if l_clone_row.open_mode = GC_PDB_NOT_EXISTS then
          fix_exception($$PLSQL_LINE, 'Reject action ' || p_action || ': parent PDB ' || p_clone_row.pdb_parent || ' not exists.');
          raise e_action_rejected;
        elsif l_clone_row.open_mode in (GC_PDB_OPEN) 
          and l_clone_row.freeze = GC_FRZ_YES then
          fix_exception($$PLSQL_LINE, 'Reject action ' || p_action || ': parent PDB ' || p_clone_row.pdb_parent || ' freeze and open mode: ' || l_clone_row.open_mode);
          raise e_action_rejected;
        end if;
      end if;
      --
    elsif not get_global_refresh then
      --
      if p_clone_row.open_mode = GC_PDB_NOT_EXISTS then
        fix_exception($$PLSQL_LINE, 'Reject action ' || p_action || ': PDB ' || p_clone_row.pdb_name || ' not exists.');
        raise e_action_rejected;
      end if;
      --
      if p_clone_row.freeze = GC_FRZ_YES then
        fix_exception($$PLSQL_LINE, 'Reject action ' || p_action || ': PDB ' || p_clone_row.pdb_name || ' freeze.');
        raise e_action_rejected;
      end if;
      --
    end if;
    --
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'check_action(' || p_action || ', ' || p_clone_row.pdb_name || ', ' || p_clone_row.pdb_parent || ')');
      raise;
  end check_action;
  
  
  function get_acfs_path(
    p_pdb_node varchar2
  ) return pdb_clones_v.acfs_path%type is
    l_result pdb_clones_v.acfs_path%type;
  begin
    --
    select c.acfs_path
    into   l_result
    from   pdb_clones_v c
    where  c.acfs_path is not null
    and    rownum = 1
    connect by prior c.pdb_parent = c.pdb_name
    start with c.pdb_name = p_pdb_node;
    --
    return l_result;
    --
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'get_acfs_path(' || p_pdb_node || ')');
      raise;
  end get_acfs_path;
  
  /**
   * ѕроцедура обработки событий (постановка в очередь, ведение списка клонов)
   *
   * p_action      - код событи€ (GC_ACT...)
   * p_pdb_name    - им€ PDB
   * p_pdb_parent  - им€ родител€ (по умолчанию - DEFAULT PARENT из pdb_clones_t)
   * p_creator     - им€ создател€ (по умолчанию USER)
   * p_planned_at  - планируема€ дата выполнени€ событи€
   * p_refreshable - режим обновлени€ (актуален только при создании клона)
   * p_freeze      - заморозка клона (актуален только при создании клона)
   *
   *  ≈сли p_refreshable или p_freeze отличны от NO - событие не будет добавлено в очередь, а
   *    в таблице PDB_CLONES_T будет содана запись о новом клоне, который будет создан при очередном обслуживании Ѕƒ 
   *    (планируетс€ раз в сутки)
   */
  procedure action(
    p_action       varchar2,
    p_pdb_name     varchar2,
    p_pdb_parent   varchar2 default null,
    p_creator      varchar2 default user,
    p_planned_at   date     default null,
    p_refreshable  varchar2 default GC_RFR_NO,
    p_freeze       varchar2 default GC_FRZ_NO
  ) is
    l_clone_row      pdb_clones_v%rowtype;
  begin
    --
    l_clone_row.pdb_name    := upper(p_pdb_name);
    l_clone_row.creator     := p_creator;
    l_clone_row.refreshable := p_refreshable;
    l_clone_row.freeze      := p_freeze;

    if p_action = GC_ACT_CLONE then
      l_clone_row.pdb_parent := nvl(upper(p_pdb_parent), G_PDB_DEFAULT);
      l_clone_row.acfs_path   := get_acfs_path(l_clone_row.pdb_parent);
    end if;
    --
    get_clone_row(p_clone_row => l_clone_row);
    --
    check_action(
      p_action     => p_action    ,
      p_clone_row  => l_clone_row
    );
    --
    if p_action = GC_ACT_CLONE and l_clone_row.id is null then
      --
      insert_clone_row(l_clone_row);
      --
    end if;
    --
    create_action(
      p_action     => p_action,
      p_pdb_name   => l_clone_row.pdb_name  ,
      p_pdb_parent => l_clone_row.pdb_parent,
      p_pdb_path   => l_clone_row.acfs_path || '/' || l_clone_row.pdb_name,
      p_planned_at => p_planned_at
    );
    --
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'action(' || p_action || ', ' || p_pdb_name || ', ' || p_pdb_parent || ')');
      raise;
  end action;
  
  procedure restore_open_mode is
  begin
    set_global_refresh;
    for p in (
        select t.pdb_name,
               t.last_open_mode
        from   pdb_clones_v t
        where  t.open_mode <> GC_PDB_NOT_EXISTS
    ) loop
      action(
        p_action      => case p.last_open_mode
                            when GC_PDB_OPEN      then GC_ACT_OPEN
                            when GC_PDB_READ_ONLY then GC_ACT_OPEN_RO
                            when GC_PDB_CLOSE     then GC_ACT_CLOSE
                         end,
        p_pdb_name    => p.pdb_name
      );
    end loop;
    commit;
    unset_global_refresh;
  exception
    when others then
      rollback;
      fix_exception($$PLSQL_LINE, 'restore_open_mode');
      raise;
  end restore_open_mode;
  
  procedure recreate_pdbs(
    p_pdb_node varchar2
  ) is
    cursor l_clones_cur(p_open_mode varchar2 default null) is
      select t.pdb_name,
             t.pdb_parent,
             t.open_mode,
             t.refreshable,
             t.last_open_mode,
             t.creator,
             (select c.freeze from pdb_clones c where c.pdb_name = t.pdb_parent) parent_freeze,
             level lvl
      from   pdb_clones_v t
      where  t.open_mode = coalesce(p_open_mode, t.open_mode) --'NOT EXISTS'
      start  with t.pdb_name = p_pdb_node
      connect by prior t.pdb_name = t.pdb_parent
      order by  level, t.pdb_created;
    
    l_action varchar2(32);
    
    procedure delete_clones(
      p_pdb_name varchar2
    ) is
      pragma autonomous_transaction;
    begin
      delete from pdb_clones_t c
        where c.pdb_name = p_pdb_name;
      commit;
    exception
      when others then
        rollback;
    end delete_clones;
    
  begin
    --
    set_global_refresh;
        
    for p in l_clones_cur('NOT EXISTS') loop
      if p.refreshable = 'NO' then
        put_log('delete clone: ' || p.pdb_name);
        delete_clones(p.pdb_name);
        continue;
      end if;
      
      put_log(GC_ACT_CLONE || ': ' || p.pdb_name || ' from ' || p.pdb_parent);
      
      action(
        p_action      => GC_ACT_CLONE,
        p_pdb_name    => p.pdb_name,
        p_pdb_parent  => p.pdb_parent,
        p_creator     => p.creator
      );
    end loop;
    
    for p in l_clones_cur loop
      if p.open_mode <> p.last_open_mode then
        l_action := case p.last_open_mode
          when GC_PDB_CLOSE     then GC_ACT_CLOSE
          when GC_PDB_READ_ONLY then GC_ACT_OPEN_RO
          when GC_PDB_OPEN      then GC_ACT_OPEN
          else null--dbms_output.put_line('Unknow mode: ' || l_clones(i).last_open_mode);
        end;
        if l_action is not null then
          put_log(l_action || ': ' || p.pdb_name);
          action(
            p_action   => l_action,
            p_pdb_name => p.pdb_name
          );
        end if;
      end if;
    end loop;
    
    unset_global_refresh;
    --
    commit;
  exception
    when others then
      rollback;
      fix_exception($$PLSQL_LINE, 'recreate_pdbs(' || p_pdb_node || ')');
      raise;
  end recreate_pdbs;
 
  
  procedure refresh_pdbs(
    p_action     varchar2,
    p_planned_at date    default sysdate,
    p_synch_mode boolean default false
  ) is
    
    l_start_time date;
    
    procedure save_open_modes_ is
      pragma autonomous_transaction;
    begin
      update pdb_clones_v c
      set    c.last_open_mode = c.open_mode
      where  c.open_mode <> GC_PDB_NOT_EXISTS
      and    c.last_open_mode is null;
      commit;
    exception
      when others then
        rollback;
        fix_exception($$PLSQL_LINE, 'save_open_modes_ failed');
        raise;
    end save_open_modes_;
    
    procedure restore_open_mode_ is
    begin
      set_global_refresh;
      for p in (
          select t.pdb_name,
                 t.last_open_mode
          from   pdb_clones_v t
          where  t.open_mode = GC_PDB_CLOSE
      ) loop
        action(
          p_action      => case p.last_open_mode
                              when GC_PDB_OPEN      then GC_ACT_OPEN
                              when GC_PDB_READ_ONLY then GC_ACT_OPEN_RO
                              when GC_PDB_CLOSE     then GC_ACT_CLOSE
                           end,
          p_pdb_name    => p.pdb_name
        );
      end loop;
      commit;
      unset_global_refresh;
    end restore_open_mode_;
    
    procedure drop_pdbs_ is
      
      cursor l_drop_pdbs_cur is
        select t.id,
               t.pdb_name
        from   pdb_clones_v t
        where  t.freeze = 'NO'
        and    t.childs_freeze = 'NO'
        and    t.open_mode <> GC_PDB_NOT_EXISTS
        and    not exists (
                 select 1
                 from   pdb_clones_v cc
                 where  cc.pdb_created > t.pdb_created
                 and    cc.open_mode <> GC_PDB_NOT_EXISTS
                 and    (cc.freeze = 'YES' or cc.childs_freeze = 'YES')
               )
        order by t.pdb_created desc;
    begin
      for p in l_drop_pdbs_cur loop
        
        action(
          p_action   => GC_ACT_DROP,
          p_pdb_name => p.pdb_name
        );
        
      end loop;
      commit;
    end drop_pdbs_;
    
    procedure create_pdbs_ is
      
      cursor l_create_pdbs_cur is
        select t.pdb_name,
               t.pdb_parent,
               t.last_open_mode
        from   pdb_clones_v t
        where  t.open_mode = GC_PDB_NOT_EXISTS
        start with t.pdb_parent is null
        connect by prior t.pdb_name = t.pdb_parent
        order by level;
      
      type l_pdbs_tbl_type is table of l_create_pdbs_cur%rowtype;
      l_pdbs_tbl l_pdbs_tbl_type;
    begin
      set_global_refresh;
      
      open l_create_pdbs_cur;
      fetch l_create_pdbs_cur bulk collect into l_pdbs_tbl;
      close l_create_pdbs_cur;
      
      for i in 1..l_pdbs_tbl.count loop
        action(
          p_action     => GC_ACT_CLONE,
          p_pdb_name   => l_pdbs_tbl(i).pdb_name,
          p_pdb_parent => l_pdbs_tbl(i).pdb_parent
        );
      end loop;
      
      for i in 1..l_pdbs_tbl.count loop
        if l_pdbs_tbl(i).last_open_mode in (GC_PDB_OPEN, GC_PDB_CLOSE) then
          action(
            p_action     => case l_pdbs_tbl(i).last_open_mode
                              when GC_PDB_OPEN      then GC_ACT_OPEN
                              when GC_PDB_CLOSE     then GC_ACT_CLOSE
                            end,
            p_pdb_name   => l_pdbs_tbl(i).pdb_name
          );
        end if;
      end loop;
      
      commit;
      
      unset_global_refresh;
    end create_pdbs_;
    
    function is_drop_process_ return boolean is
      l_dummy int;
    begin
      select 1
      into   l_dummy
      from   pdb_actions_v a
      where  rownum = 1
      and    a.action = GC_ACT_DROP
      and    a.status in ('NEW', 'PROCESS');
      
      return true;
      
    exception
      when no_data_found then
        return false;
    end is_drop_process_;
    
  begin
    put_log('Start refresh PDBS: ' || p_action);
    --
    case p_action
      /*when GC_RFSH_START  then
        /*create_action(
          p_action     => GC_ACT_REFRESH,
          p_pdb_name   => GC_ACT_REFRESH,
          p_pdb_parent => GC_RFSH_DROP,
          p_planned_at => p_planned_at
        );*/
      when GC_RFSH_DROP   then
        save_open_modes_;
        drop_pdbs_;
        
        if p_synch_mode then
          l_start_time := sysdate;
          while(is_drop_process_) loop
            dbms_lock.sleep(20);
            if sysdate - L_start_time > (1 / 24 * 2) then
              fix_exception($$PLSQL_LINE, 'refresh_pdbs failed');
              raise program_error;
            end if;
          end loop;
        end if;
        /*create_action(
          p_action     => GC_ACT_REFRESH,
          p_pdb_name   => GC_ACT_REFRESH,
          p_pdb_parent => GC_RFSH_CREATE,
          p_planned_at => sysdate + 1/1440 * 15
        );*/
      when GC_RFSH_CREATE then
        restore_open_mode_;
        create_pdbs_;
        
        /*create_action(
          p_action     => GC_ACT_REFRESH,
          p_pdb_name   => GC_ACT_REFRESH,
          p_pdb_parent => GC_RFSH_DROP,
          p_planned_at => trunc(sysdate + 1)--/1440
        );--*/
      when GC_RFSH_RESTORE_MODE then
        restore_open_mode_;
      else
        raise no_data_found;
    end case;
    --
    commit;
    --
    put_log('Complete refresh PDBS: ' || p_action);
  exception
    when others then
      rollback;
      fix_exception($$PLSQL_LINE, 'refresh_pdbs failed');
      raise;
  end refresh_pdbs;
  
  
  
  /**
   * ѕроцедура add_database добавл€ет описание реальной Ѕƒ в PDB_NODE.PDB_CLONES_T
   *   и создает базовый клон
   *
   * p_pdb_name          - им€ Ѕƒ
   * p_clone_name        - им€ базового клона
   * p_acfs_path         - путь к точке монтировани€ ACFS, в корне д.б. директори€ с созданной PDB
   *
   */
  procedure add_database(
    p_pdb_name          varchar2,
    p_clone_name        varchar2,
    p_acfs_path         varchar2
  ) is
    
    l_pdb_row      pdb_clones_v%rowtype;

    procedure add_pdb_node_ is
    begin
      
      get_clone_row(p_clone_row => l_pdb_row);
      
      if l_pdb_row.id is not null then
        fix_exception('PDB NODE ' || p_pdb_name || ' already exists');
        raise too_many_rows;
      end if;
      
      insert_clone_row(p_clone_row => l_pdb_row);
      
    exception
      when others then
        fix_exception($$PLSQL_LINE, 'add_pdb_node_');
        raise;
    end add_pdb_node_;
    
    procedure create_base_clone_(p_clone_name varchar2) is
      l_clone_row pdb_clones_v%rowtype;
    begin
      
      put_log('Create base clone ' || p_clone_name || ' for ' || p_pdb_name);
      
      action(
        p_action      => GC_ACT_CLONE,
        p_pdb_name    => p_clone_name,
        p_pdb_parent  => l_pdb_row.pdb_name,
        p_creator     => user,
        p_refreshable => GC_RFR_PARENT
      );
      
      l_clone_row.pdb_name := p_clone_name;
      
      get_clone_row(p_clone_row => l_clone_row);
      
      action(
        p_action      => GC_ACT_OPEN_RO,
        p_pdb_name    => l_clone_row.pdb_name
      );
      
      l_clone_row.freeze := GC_FRZ_YES;
      update_clone(
        p_clone_row => l_clone_row
      );
      
    exception
      when others then
        fix_exception($$PLSQL_LINE, 'create_base_clone_');
    end create_base_clone_;
    
  begin
    
    l_pdb_row.pdb_name    := upper(p_pdb_name);
    l_pdb_row.refreshable := GC_RFR_NO;
    l_pdb_row.freeze      := GC_FRZ_NO;
    l_pdb_row.thin_clone  := 'NO';
    l_pdb_row.acfs_path   := p_acfs_path;
    l_pdb_row.creator     := user;
    l_pdb_row.open_mode   := GC_PDB_CREATION;
    
    put_log('Add PDB NODE: ' || l_pdb_row.pdb_name || ' (' || l_pdb_row.acfs_path || ')');
    
    add_pdb_node_;
    
    create_base_clone_(
      p_clone_name => upper(p_clone_name)
    );
    
    action(
      p_action      => GC_ACT_CLOSE,
      p_pdb_name    => l_pdb_row.pdb_name
    );
    
    l_pdb_row.freeze := GC_FRZ_YES;
    update_clone(p_clone_row => l_pdb_row);
    
    commit;
    
  exception
    when others then
      rollback;
      fix_exception($$PLSQL_LINE, 'add_pdb_node failed');
      raise;
  end add_database;
  
begin
  init$;
end pdb_api;
/
