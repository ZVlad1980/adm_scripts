create or replace package body pdb_daemon_api is
  
  GC_UNIT_NAME constant varchar2(32) := $$PLSQL_UNIT;
  
  GC_PDB_DAEMON      constant varchar2(30) := 'PDB_DAEMON';
  GC_PDB_DAEMON_STOP constant varchar2(50) := GC_PDB_DAEMON || '_STOP';
  GC_TIMEOUT         constant int := 10;
  
  GC_STS_SUCCESS constant varchar2(10) := 'SUCCESS';
  --GC_STS_NEW     constant varchar2(10) := 'NEW';
  GC_STS_PROCESS constant varchar2(10) := 'PROCESS';
  GC_STS_ERROR   constant varchar2(10) := 'ERROR';
  GC_STS_UNKNOWN constant varchar2(10) := 'UNKN_ACT';
  
  GC_PDB_OPEN       constant varchar2(15) := 'READ WRITE';
  GC_PDB_CLOSE      constant varchar2(15) := 'MOUNTED';
  GC_PDB_READ_ONLY  constant varchar2(15) := 'READ ONLY';
  GC_PDB_NOT_EXISTS constant varchar2(15) := 'NOT EXISTS';
  --GC_PDB_NOT_FOUND  constant varchar2(15) := 'NOT FOUND';
  
  GC_ACT_CLONE      constant varchar2(32) := 'CLONE';
  GC_ACT_CLOSE      constant varchar2(32) := 'CLOSE';
  GC_ACT_OPEN       constant varchar2(32) := 'OPEN';
  GC_ACT_OPEN_RO    constant varchar2(32) := 'OPEN_RO';
  GC_ACT_DROP       constant varchar2(32) := 'DROP';
  GC_ACT_REFRESH    constant varchar2(32) := 'REFRESH';
  
  GC_ST_DM_NORMAL   constant varchar2(20) := 'NORMAL';
  GC_ST_DM_CRITICAL constant varchar2(20) := 'CRITICAL';
  GC_ST_DM_ERROR    constant varchar2(20) := 'ERROR';
  
  GC_STS_DM_STOP    constant varchar2(20) := 'STOP';
  GC_STS_DM_START   constant varchar2(20) := 'START';
  GC_STS_DM_PAUSE   constant varchar2(20) := 'PAUSE';
  
  type g_error_rec_typ is record (
    exists            int,
    error_msg         varchar2(4000),
    critical          boolean,
    error_stack       varchar2(2000),
    error_backtrace   varchar2(2000),
    call_stack        varchar2(2000)
  );
  g_error g_error_rec_typ;
  
  
  cursor g_actions_cur is
    select a.id        ,
           a.action    ,
           a.pdb_name  ,
           a.pdb_parent,
           a.pdb_path,
           a.result    ,
           a.status    ,
           a.start_process,
           a.end_process,
           a.critical
    from   pdb_actions_new a
    order by a.planned_at nulls first, a.created_at;
  
  
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
      append_error_('Error stack', p_error.error_stack);
      append_error_('Error backtrace', p_error.error_backtrace);
      append_error_('Call stack', p_error.call_stack);
    end if;
    
    insert into pdb_daemon_log(
      message,
      error
    ) values (
      nvl(substr(p_msg, 1, 500), p_error.error_msg),
      l_error
    );
    
    commit;

  exception
    when others then
      rollback;
      raise;
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
  
  procedure ei(p_cmd varchar2) is
  begin
    put_log(GC_PDB_DAEMON || ': ' || p_cmd);
    execute immediate p_cmd;
    put_log(GC_PDB_DAEMON || ' complete');
  exception
    when others then
      fix_exception($$PLSQL_LINE, GC_PDB_DAEMON || ' failed: ' || sqlerrm, true);
      raise;
  end;
  
  function get_status_pdb(
    p_pdb_name varchar2
  ) return v$pdbs.open_mode%type is
    l_result v$pdbs.open_mode%type;
  begin
    --
    select p.open_mode
    into   l_result
    from   v$pdbs p
    where  p.name = p_pdb_name;
    --
    return l_result;
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'get_status_pdb: PDB ' || p_pdb_name || ' failed.');
      raise;
  end get_status_pdb;
  
  function get_directory(
    p_directory_name varchar2
  ) return dba_directories.DIRECTORY_PATH%type is
    l_result dba_directories.DIRECTORY_PATH%type;
  begin
    
    select dd.DIRECTORY_PATH
    into   l_result
    from   dba_directories dd
    where  dd.DIRECTORY_NAME = p_directory_name;
    
    return l_result;
    
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'get_directory(' || p_directory_name || '): failed');
      raise;
  end get_directory;
  
  function is_exists_pdb(
    p_pdb_name varchar2
  ) return boolean is
    l_dummy int;
  begin

    select 1
    into   l_dummy
    from   v$pdbs p
    where  p.name = p_pdb_name;

    return true;
  
  exception
    when no_data_found then
      return false;
    when others then
      fix_exception($$PLSQL_LINE, 'is_exists_pdb: PDB ' || p_pdb_name || ' failed.');
      raise;
  end is_exists_pdb;
  
  function is_clone_pdb(
    p_pdb_name varchar2
  ) return boolean is
    l_dummy pdb_clones.pdb_parent%type;
  begin

    select p.pdb_parent
    into   l_dummy
    from   pdb_clones p
    where  p.pdb_name = p_pdb_name;

    return l_dummy is not null;
  
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'is_clone_pdb: PDB ' || p_pdb_name || ' failed.');
      raise;
  end is_clone_pdb;
  
  function is_clone_of_clone_pdb(
    p_pdb_name varchar2
  ) return boolean is
    l_dummy pdb_clones.pdb_parent%type;
  begin

    select p.clone_of_clone
    into   l_dummy
    from   pdb_clones p
    where  p.pdb_name = p_pdb_name;

    return l_dummy = 'YES';
  
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'is_clone_of_clone_pdb: PDB ' || p_pdb_name || ' failed.');
      raise;
  end is_clone_of_clone_pdb;
  
  function is_exists_child(
    p_pdb_name varchar2
  ) return boolean is
    l_result pdb_clones.childs_exists%type;
  begin

    select p.childs_exists
    into   l_result
    from   pdb_clones p
    where  p.pdb_name = p_pdb_name;

    return l_result = 'YES';
  
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'is_clone_pdb: PDB ' || p_pdb_name || ' failed.');
      raise;
  end is_exists_child;
  
  procedure close_pdb(
    p_pdb_name   in  varchar2,
    p_force      in  boolean default true
  ) is
    l_status v$pdbs.open_mode%type;
  begin
    l_status := get_status_pdb(p_pdb_name);
    if l_status = GC_PDB_CLOSE then
      return;
    end if;
    --
    ei('alter pluggable database ' || p_pdb_name || ' close' || case when p_force then ' immediate' end);
    --
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'close_pdb(' || p_pdb_name || '): failed');
      raise;
  end close_pdb;
  
  procedure open_pdb(
    p_pdb_name   in  varchar2,
    p_force      boolean default true
  ) is
    l_status v$pdbs.open_mode%type;
  begin
    --
    l_status := get_status_pdb(p_pdb_name);
    --
    if l_status = GC_PDB_OPEN then
      return;
    elsif l_status = GC_PDB_READ_ONLY then
      if not p_force then
        fix_exception($$PLSQL_LINE, 'open_pdb: PDB ' || p_pdb_name || ' already open mode ' || l_status);
        raise program_error;
      end if;
      close_pdb(p_pdb_name);
    end if;
    --
    ei('alter pluggable database ' || p_pdb_name || ' open read write ' || case when p_force then 'force' end);
    --
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'open_pdb(' || p_pdb_name || ', ' || case when p_force then 'FORCE' end || '): failed');
      raise;
  end open_pdb;
  
  procedure open_ro_pdb(
    p_pdb_name   in  varchar2,
    p_force      boolean default true
  ) is
    l_status v$pdbs.open_mode%type;
  begin
    
    l_status := get_status_pdb(p_pdb_name);
    
    if l_status = GC_PDB_READ_ONLY then
      return;
    elsif l_status = GC_PDB_OPEN then
      if not p_force then
        fix_exception($$PLSQL_LINE, 'open_ro_pdb: PDB ' || p_pdb_name || ' already open mode ' || l_status);
        raise program_error;
      end if;
      close_pdb(p_pdb_name);
    end if;
    --
    ei('alter pluggable database ' || p_pdb_name || ' open read only');
    --
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'open_ro_pdb(' || p_pdb_name || ', ' || case when p_force then 'FORCE' end || '): failed');
      raise;
  end open_ro_pdb;
  
  function get_fn_convert(
    p_pdb_source in  varchar2,
    p_pdb_target in  varchar2,
    p_pdb_path   in  varchar2
  ) return varchar2 is
    l_result varchar2(32767);
    
    l_first  boolean := true;
    
    cursor l_pdb_files_cur(p_pdb_name varchar2, p_ts varchar2 default null) is
      select pdb.tablespace_name,
             lpad(to_char(pdb.file_num), 2, '0') file_num,
             pdb.file_name,
             pdb.full_file_name,
             pdb.pdb_path,
             pdb.file_path
      from   cdb_all_files_v pdb
      where  1=1
      and    pdb.tablespace_name = nvl(p_ts, pdb.tablespace_name)
      and    pdb.pdb_name = p_pdb_name
      order by pdb.tablespace_name, pdb.file_num;
    
    procedure append_(p_path varchar2) is
    begin
      l_result := l_result || case when l_result is not null then ', ' end || '''' || p_path || '''';
    end;
    
  begin
    
    for f in l_pdb_files_cur(p_pdb_source) loop
      if f.tablespace_name = 'TEMP' then
        append_(f.full_file_name);
        append_(f.file_path || '/' || lower(p_pdb_target || '_TEMP_' || f.file_num || '.dbf'));
      elsif f.file_name like 'o__mf_%' then
        append_(f.full_file_name);
        append_(replace(f.file_path, f.pdb_path, p_pdb_path) || '/' || lower(p_pdb_target || '_' || f.tablespace_name || '_' || f.file_num || '.dbf'));
      elsif l_first then
        append_(f.file_path);
        append_(replace(f.file_path, f.pdb_path, p_pdb_path));
        l_first := false; --общий путь добавляем только один раз
      end if;
    end loop;
    
    return l_result;
    
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'get_fn_convert(' || p_pdb_source || ', ' || p_pdb_target || ', ' || p_pdb_path || '): failed');
      raise;
  end get_fn_convert;
  
  procedure clone_pdb(
    p_pdb_source in  varchar2,
    p_pdb_target in  varchar2,
    p_pdb_path   in  varchar2
  ) is
    
    l_file_name_convert varchar2(32700);
    
  begin
    --
    l_file_name_convert := 'file_name_convert=(' || get_fn_convert(p_pdb_source, p_pdb_target, p_pdb_path) || ')';
    put_log(substr(l_file_name_convert, 1, 400));
    ei('create pluggable database ' || p_pdb_target || ' from ' || p_pdb_source || ' snapshot copy ' || l_file_name_convert);
    --
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'clone_pdb(' || p_pdb_source || ', ' || p_pdb_target || '): failed');
      raise;
  end clone_pdb;
  
  procedure clone_of_clone_pdb(
    p_pdb_source in   varchar2,
    p_pdb_target in   varchar2
  ) is
    
    C_CLONE_CONF      constant varchar2(120) := 'clone_pdb.conf';
    C_COPY_FILE       constant varchar2(32)  := 'create_db_files.cmd';
    C_DESCRIBE_XML    constant varchar2(120) := 'clone_pdb.xml';
    C_CLONE_DIR       constant varchar2(32)  := 'PDB_CLONES_DIR';
    C_SNAP_TMPL       constant varchar2(32)  := '/.ACFS/snaps/';
    
    cursor l_pdb_files_cur(p_pdb_name varchar2, p_ts varchar2) is
      select pdb.tablespace_name,
             pdb.file_num,
             pdb.file_name,
             pdb.full_file_name,
             pdb.pdb_path,
             pdb.file_path
      from   cdb_all_files_v pdb
      where  1=1
      and    pdb.tablespace_name = nvl(p_ts, pdb.tablespace_name)
      and    pdb.pdb_name = p_pdb_name
      order by pdb.tablespace_name, pdb.file_num;
    
    l_pdb_path_row    l_pdb_files_cur%rowtype;
    
    l_path_descr_xml  dba_directories.DIRECTORY_PATH%type; --путь к директории PDB_CLONES_DIR
    
    cursor l_pdb_files_ext_cur is
      select regexp_substr(e.message, '[^ ]+', 1, 9)       file_name,
             substr(e.message, instr(e.message, '->') + 3) link
      from   files_pdb_ext_t e
      where  e.message like 'l%';
    
    type l_files_tbl_typ is table of l_pdb_files_ext_cur%rowtype index by pls_integer;
    
    l_pdb_files       l_files_tbl_typ;
    
    type l_params_tbl_typ is table of varchar2(512) index by varchar2(60);
    l_params l_params_tbl_typ;
      
    type l_temp_file_rec is record(
      source varchar2(2000),
      target varchar2(2000)
    );
    type l_temp_files_tbl is table of l_temp_file_rec index by binary_integer;
    
    l_temp_files l_temp_files_tbl;
    
    procedure push_param_(p_name varchar2, p_value varchar2) is
    begin
      l_params(p_name) := p_value;
    end push_param_;
    
    procedure get_pdb_path_row_(p_pdb_path_row in out nocopy l_pdb_files_cur%rowtype) is
    begin
      
      open l_pdb_files_cur(p_pdb_source, 'SYSTEM');
      fetch l_pdb_files_cur into p_pdb_path_row;
      if l_pdb_files_cur%notfound then
        raise no_data_found;
      end if;
      close l_pdb_files_cur;
      
    exception
      when others then
        if l_pdb_files_cur%isopen then
          close l_pdb_files_cur;
        end if;
        fix_exception($$PLSQL_LINE, 'get_pdb_path_row_: failed');
        raise;
    end get_pdb_path_row_;
    
    procedure get_pdb_files_ is
    begin
      
      open l_pdb_files_ext_cur;
      fetch l_pdb_files_ext_cur bulk collect into l_pdb_files;
      close l_pdb_files_ext_cur;
      
      if l_pdb_files.count = 0 then
        raise no_data_found;
      end if;
      
    exception
      when others then
        fix_exception($$PLSQL_LINE, 'get_pdb_files_: failed');
        raise;
    end get_pdb_files_;
    
    function get_parent_snap_(p_path varchar2) return varchar2 is
      l_start  int;
      l_length int;
    begin
      l_start  := instr(p_path, C_SNAP_TMPL, 1, 1) + length(C_SNAP_TMPL);
      l_length := instr(p_path, '/', l_start, 1) - l_start;
      return substr(p_path, l_start, l_length);
    end get_parent_snap_;
    
    function get_acfs_mount_(p_path varchar2) return varchar2 is
    begin
      return substr(p_path, 1, instr(p_path, C_SNAP_TMPL, 1, 1) - 1);
    end get_acfs_mount_;
    
    procedure build_temp_files_ is
    begin
      for f in l_pdb_files_cur(p_pdb_source, 'TEMP') loop
        l_temp_files(l_temp_files.count + 1).source := f.full_file_name;
        l_temp_files(l_temp_files.count    ).target := f.file_path || '/' || lower(p_pdb_target || '_TEMP_' || lpad(to_char(f.file_num), 2, '0') || '.dbf');
      end loop;
    exception
      when others then
        fix_exception($$PLSQL_LINE, 'build_temp_files_: failed');
        raise;
    end build_temp_files_;
    
    procedure create_conf_file_ is
      l_file         utl_file.file_type;
      l_curr         varchar2(60);
    begin
      
      l_file := utl_file.fopen(
        location     => C_CLONE_DIR,
        filename     => C_CLONE_CONF,
        open_mode    => 'w'
      );
      
      l_curr := l_params.first();
      while l_curr is not null loop
        utl_file.put_line(l_file, l_curr || '=' || l_params(l_curr));
        l_curr := l_params.next(l_curr);
      end loop;
      
      utl_file.fclose(l_file);
    exception
      when others then
        fix_exception($$PLSQL_LINE, 'create_conf_file_: failed');
        raise;
    end create_conf_file_;
    
    procedure create_copy_file_ is
      l_file         utl_file.file_type;
    begin
      
      l_file := utl_file.fopen(
        location     => C_CLONE_DIR,
        filename     => C_COPY_FILE,
        open_mode    => 'w'
      );
      
      utl_file.put_line(l_file, '/usr/sbin/acfsutil snap create -w -p $parent_snap $pdb_target $acfs_mount'); --1> snap_create.log 2> snap_create.log
      utl_file.put_line(l_file, '/bin/mkdir -p $pdb_target_pdb');
      utl_file.put_line(l_file, '/bin/mkdir -p $pdb_target_path');

      for i in 1..l_pdb_files.count loop
        utl_file.put_line(
          l_file, 
          '/bin/ln -sf ' || 
            replace(
              l_pdb_files(i).link, 
              l_params('parent_snap'), 
              l_params('pdb_target')
            ) || ' $pdb_target_path/' || l_pdb_files(i).file_name
        );
      end loop;
      
      for i in 1..l_temp_files.count loop
        utl_file.put_line(
          l_file,
          '/bin/cp ' ||
            l_temp_files(i).source || ' ' ||
            l_temp_files(i).target
        );
      end loop;
      
      utl_file.fclose(l_file);
      
    exception
      when others then
        fix_exception($$PLSQL_LINE, 'create_copy_file_: failed');
        raise;
    end create_copy_file_;
    
    procedure create_describe_xml_ is

      l_describe_xml clob;
      
      procedure get_describe_xml_ is
        l_file   BFILE;
      begin
        
        l_file := bfilename(C_CLONE_DIR, C_DESCRIBE_XML);
        
        dbms_lob.fileopen(l_file, dbms_lob.lob_readonly);
        dbms_lob.loadfromfile(l_describe_xml, l_file, dbms_lob.getlength(l_file));
        dbms_lob.fileclose(l_file);
        
      exception
        when others then
          fix_exception($$PLSQL_LINE, 'get_describe_xml_: failed');
          raise;
      end get_describe_xml_;
      
      procedure prepare_xml_ is
      begin
        
        l_describe_xml := replace(
          l_describe_xml,
          l_params('pdb_source_path'), 
          l_params('pdb_target_path')
        );
        
        for i in 1..l_temp_files.count loop
          l_describe_xml := replace(
            l_describe_xml,
            l_temp_files(i).source,
            l_temp_files(i).target
          );
        end loop;
        
      exception
        when others then
          fix_exception($$PLSQL_LINE, 'prepare_xml_: failed');
          raise;
      end prepare_xml_;
      
      procedure put_describe_xml_ is
        
        procedure clob2file_ is
          l_file         utl_file.file_type;
          l_str          varchar2(32767);
          l_offset       integer := 1;
          l_new_line     varchar2(1) := chr(10);
          l_max_length   integer;
          
          function get_str_(p_str out varchar2) return boolean is
            l_position integer;
          begin
            if l_offset >= l_max_length then
              return false;
            end if;
            
            l_position := instr(l_describe_xml, l_new_line, l_offset);
            
            if l_position <= 0 then
              l_position := l_max_length;
            end if;
            
            p_str := dbms_lob.substr(
              lob_loc => l_describe_xml,
              amount  => (l_position - l_offset),
              offset  => l_offset
            ); 
            
            l_offset := l_position + 1;
            
            return true;
          end;
          
        begin
          
          l_file := utl_file.fopen(
            location  => c_clone_dir,
            filename  => c_describe_xml,
            open_mode => 'w'
          );
          
          l_max_length := dbms_lob.getlength(l_describe_xml);
        
          while get_str_(l_str) loop
            utl_file.put_line(l_file, l_str);
          end loop;
        
          utl_file.fclose(l_file);
          
        end clob2file_;
        
      begin
        clob2file_;
      null;
      exception
        when others then
          fix_exception($$PLSQL_LINE, 'put_describe_xml_: failed');
          raise;
      end put_describe_xml_;
      
    begin
      
      begin
        utl_file.fremove(location => C_CLONE_DIR, filename => C_DESCRIBE_XML);
      exception
        when others then
          put_log('XML file not found: ' || l_path_descr_xml || '/' || C_DESCRIBE_XML || ' Error: ' || sqlerrm);
      end;
      --*/
      begin
        dbms_pdb.describe(
          pdb_descr_file => l_path_descr_xml,
          pdb_name       => p_pdb_source
        );
      exception
        when others then
          fix_exception($$PLSQL_LINE, 'dbms_pdb.describe(' || l_path_descr_xml || ', ' || p_pdb_source || '): failed');
          raise;
      end;
      
      --
      dbms_lob.createtemporary(l_describe_xml, false);
      
      get_describe_xml_;
      prepare_xml_;
      put_describe_xml_;
      
      dbms_lob.freetemporary(l_describe_xml);
      
    exception
      when others then
        fix_exception($$PLSQL_LINE, 'create_describe_xml_: failed');
        raise;
    end create_describe_xml_;
    
    procedure create_snapshot_ is
    begin
      
      for log in (select message from clone_pdb_ext_t) loop
        put_log(log.message);
      end loop;
      
    exception
      when others then
        fix_exception($$PLSQL_LINE, 'create_snapshot_: failed', true);
        raise;
    end create_snapshot_;
    
  begin
    
    l_path_descr_xml := get_directory(C_CLONE_DIR) || '/' || C_DESCRIBE_XML;
    
    push_param_('pdb_source', p_pdb_source);
    push_param_('pdb_target', p_pdb_target);
    
    get_pdb_path_row_(l_pdb_path_row);
    push_param_('pdb_source_path', l_pdb_path_row.file_path);
    push_param_('pdb_target_pdb', substr(l_pdb_path_row.pdb_path, 1, instr(l_pdb_path_row.pdb_path, '/', -1)) || p_pdb_target);
    push_param_('pdb_target_path', 
      l_params('pdb_target_pdb') || substr(l_pdb_path_row.file_path, instr(l_pdb_path_row.file_path, '/', -1))
    );
    create_conf_file_;
    
    get_pdb_files_; --список символьных ссылок на файлы БД

    push_param_('parent_snap', get_parent_snap_(l_pdb_files(1).link));
    push_param_('acfs_mount', get_acfs_mount_(l_pdb_files(1).link));
    create_conf_file_;

    build_temp_files_;
    create_conf_file_;    --Файл параметров
    create_describe_xml_; --XML описание создаваемого клона
    create_copy_file_;    --Файл создания файлов БД
    create_snapshot_;     --вызов скрипта создания снапшота и файлов целевой PDB (включая temp)
    --
    ei('create pluggable database ' || p_pdb_target || ' as clone using ''' || l_path_descr_xml || ''' nocopy tempfile reuse');
    --create pluggable database VBZ_PDB002 as clone using '/ora1/dat/pdbs/tempfiles/clones/clone_pdb.xml' nocopy tempfile reuse
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'clone_of_clone_pdb(' || p_pdb_source || ', ' || p_pdb_target || ')): failed');
      raise;
  end clone_of_clone_pdb;
  
  
  procedure drop_pdb(
    p_pdb_name   in  varchar2
  ) is
    l_status v$pdbs.open_mode%type;
  begin
  
    l_status := get_status_pdb(p_pdb_name);
    
    if l_status <> GC_PDB_CLOSE then
      fix_exception($$PLSQL_LINE, 'drop_pdb: PDB ' || p_pdb_name || ' open mode ' || l_status);
      raise program_error;
    end if;
    --
    if p_pdb_name in ('PDB_NODE', 'PDB_ROOT') then
      fix_exception($$PLSQL_LINE, 'drop_pdb: drop PDB ' || p_pdb_name || ' failed.');
      raise program_error;
    end if;
    --
    ei('drop pluggable database ' || p_pdb_name || ' including datafiles');
    --
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'drop_pdb(' || p_pdb_name || '): failed');
      raise;
  end drop_pdb;
  
  procedure drop_clone_pdb(
    p_pdb_name   in  varchar2
  ) is
    
    C_CLONE_CONF      constant varchar2(120) := 'clone_pdb.conf';
    C_COPY_FILE       constant varchar2(32)  := 'create_db_files.cmd';
    C_CLONE_DIR       constant varchar2(32)  := 'PDB_CLONES_DIR';
    C_SNAP_TMPL       constant varchar2(32)  := '/.ACFS/snaps/';
    
    cursor l_pdb_files_cur(p_pdb_name varchar2, p_ts varchar2) is
      select pdb.tablespace_name,
             pdb.file_num,
             pdb.file_name,
             pdb.full_file_name,
             pdb.pdb_path,
             pdb.file_path
      from   cdb_all_files_v pdb
      where  1=1
      and    pdb.tablespace_name = nvl(p_ts, pdb.tablespace_name)
      and    pdb.pdb_name = p_pdb_name
      order by pdb.tablespace_name, pdb.file_num;

    l_pdb_path_row    l_pdb_files_cur%rowtype;
    
      
    cursor l_pdb_files_ext_cur is
      select regexp_substr(e.message, '[^ ]+', 1, 9)       file_name,
             substr(e.message, instr(e.message, '->') + 3) link
      from   files_pdb_ext_t e
      where  e.message like 'l%';
  
    l_status v$pdbs.open_mode%type;
    
    type l_params_tbl_typ is table of varchar2(512) index by varchar2(60);
    l_params l_params_tbl_typ;
    
    type l_files_tbl_typ is table of l_pdb_files_ext_cur%rowtype index by pls_integer;
    
    l_pdb_files       l_files_tbl_typ;
    
    procedure push_param_(p_name varchar2, p_value varchar2) is
    begin
      l_params(p_name) := p_value;
    end push_param_;
    
    procedure get_pdb_path_row_(p_pdb_path_row in out nocopy l_pdb_files_cur%rowtype) is
    begin
      
      open l_pdb_files_cur(p_pdb_name, 'SYSTEM');
      fetch l_pdb_files_cur into p_pdb_path_row;
      if l_pdb_files_cur%notfound then
        raise no_data_found;
      end if;
      close l_pdb_files_cur;
      
    exception
      when others then
        if l_pdb_files_cur%isopen then
          close l_pdb_files_cur;
        end if;
        fix_exception($$PLSQL_LINE, 'get_pdb_path_row_: failed');
        raise;
    end get_pdb_path_row_;
    
    procedure get_pdb_files_ is
    begin
      
      open l_pdb_files_ext_cur;
      fetch l_pdb_files_ext_cur bulk collect into l_pdb_files;
      close l_pdb_files_ext_cur;
      
      if l_pdb_files.count = 0 then
        raise no_data_found;
      end if;
      
    exception
      when others then
        fix_exception($$PLSQL_LINE, 'get_pdb_files_: failed');
        raise;
    end get_pdb_files_;
    
    function get_acfs_mount_(p_path varchar2) return varchar2 is
    begin
      return substr(p_path, 1, instr(p_path, C_SNAP_TMPL, 1, 1) - 1);
    end get_acfs_mount_;
    
    function get_snap_name_(p_path varchar2) return varchar2 is
      l_start  int;
      l_length int;
    begin
      l_start  := instr(p_path, C_SNAP_TMPL, 1, 1) + length(C_SNAP_TMPL);
      l_length := instr(p_path, '/', l_start, 1) - l_start;
      return substr(p_path, l_start, l_length);
    end get_snap_name_;
    
    procedure create_conf_file_ is
      l_file         utl_file.file_type;
      l_curr         varchar2(60);
    begin
      
      l_file := utl_file.fopen(
        location     => C_CLONE_DIR,
        filename     => C_CLONE_CONF,
        open_mode    => 'w'
      );
      
      l_curr := l_params.first();
      while l_curr is not null loop
        utl_file.put_line(l_file, l_curr || '=' || l_params(l_curr));
        l_curr := l_params.next(l_curr);
      end loop;
      
      utl_file.fclose(l_file);
    exception
      when others then
        fix_exception($$PLSQL_LINE, 'create_conf_file_: failed');
        raise;
    end create_conf_file_;
    
    procedure create_rm_file_ is
      l_file         utl_file.file_type;
      cursor l_temp_files_cur(p_pdb_name varchar2) is
        select pdb.tablespace_name,
               pdb.file_num,
               pdb.file_name,
               pdb.full_file_name,
               pdb.pdb_path,
               pdb.file_path
        from   cdb_all_files_v pdb
        where  1=1
        and    pdb.tablespace_name = 'TEMP' --nvl(p_ts, pdb.tablespace_name)
        and    pdb.pdb_name = p_pdb_name
        order by pdb.tablespace_name, pdb.file_num;
    begin
      
      l_file := utl_file.fopen(
        location     => C_CLONE_DIR,
        filename     => C_COPY_FILE,
        open_mode    => 'w'
      );
      
      utl_file.put_line(l_file, '/usr/sbin/acfsutil snap delete $snap_name $acfs_mount'); --1> snap_create.log 2> snap_create.log
      utl_file.put_line(l_file, '/bin/rm -fr $pdb_path');
      
      for f in l_temp_files_cur(p_pdb_name) loop
        utl_file.put_line(
          l_file,
          '/bin/rm -f ' || f.full_file_name
        );
      end loop;
      
      utl_file.fclose(l_file);
      
    exception
      when others then
        fix_exception($$PLSQL_LINE, 'create_rm_file_: failed');
        raise;
    end create_rm_file_;
    
    procedure drop_snapshort_ is
    begin
      
      for log in (select message from clone_pdb_ext_t) loop
        put_log(log.message);
      end loop;
      
    exception
      when others then
        fix_exception($$PLSQL_LINE, 'drop_snapshort_: failed');
        raise;
    end drop_snapshort_;
    
  begin
  
    l_status := get_status_pdb(p_pdb_name);
    
    if l_status <> GC_PDB_CLOSE then
      fix_exception($$PLSQL_LINE, 'drop_pdb: PDB ' || p_pdb_name || ' open mode ' || l_status);
      raise program_error;
    end if;
    --
    get_pdb_path_row_(l_pdb_path_row);
    push_param_('pdb_name', p_pdb_name);
    push_param_('pdb_source_path', l_pdb_path_row.file_path);
    push_param_('pdb_path', l_pdb_path_row.pdb_path);
    create_conf_file_;
    get_pdb_files_;
    push_param_('acfs_mount', get_acfs_mount_(l_pdb_files(1).link));
    push_param_('snap_name', get_snap_name_(l_pdb_files(1).link));
    create_conf_file_;
    create_rm_file_;
    --
    ei('drop pluggable database ' || p_pdb_name);-- || ' including datafiles');
    --
    drop_snapshort_;
    --
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'open_ro_pdb(' || p_pdb_name || '): failed');
      raise;
  end drop_clone_pdb;
  
  
  /*
  procedure open_pdb(
    p_status     out varchar2,
    p_status_msg out varchar2,
    p_pdb_name   in  varchar2
  ) is
  begin
    open_pdb(p_pdb_name);
  exception
    when others then
      fix_exception($$PLSQL_LINE);
      p_status := GC_STS_ERROR;
      p_status_msg := get_error_msg;
      raise;
  end open_pdb;
  
  /*procedure open_ro_pdb(
    p_status     out varchar2,
    p_status_msg out varchar2,
    p_pdb_name   in  varchar2
  ) is
  begin
    open_ro_pdb(p_pdb_name);
  exception
    when others then
      fix_exception($$PLSQL_LINE);
      p_status := GC_STS_ERROR;
      p_status_msg := get_error_msg;
      raise;
  end open_ro_pdb;
  
  procedure close_pdb(
    p_status     out varchar2,
    p_status_msg out varchar2,
    p_pdb_name   in  varchar2
  ) is
  begin
    close_pdb(p_pdb_name);
  exception
    when others then
      fix_exception($$PLSQL_LINE);
      p_status := GC_STS_ERROR;
      p_status_msg := get_error_msg;
      raise;
  end close_pdb;
  
  /*-- Private type declarations
  procedure clone_pdb(
    p_status     out varchar2,
    p_status_msg out varchar2,
    p_pdb_source in  varchar2,
    p_pdb_target in  varchar2,
    p_fn_convert in  sys.odcivarchar2list default null
  ) is
  begin
    --
    open_ro_pdb(p_pdb_source, p_force => true);
    clone_pdb(p_pdb_source, p_pdb_target, p_fn_convert);
    open_pdb(p_pdb_target, p_force => true);
    --
    p_status := GC_STS_SUCCESS;
    --
  exception
    when others then
      fix_exception($$PLSQL_LINE);
      p_status := GC_STS_ERROR;
      p_status_msg := get_error_msg;
      raise;
  end clone_pdb;*/
  
  function lock$(
    p_lock_name varchar2
  ) return integer is
    l_lock_handle varchar2(50);
    l_result      integer;
  begin
    
    dbms_lock.allocate_unique(
      lockname        => p_lock_name,
      lockhandle      => l_lock_handle
    );

    l_result := dbms_lock.request(
      lockhandle        => l_lock_handle,
      timeout           => 0
    );
    
    return l_result;
    
  end lock$;
  
  procedure lock$(
    p_lock_name varchar2
  ) is
    l_dummy integer;
  begin
    l_dummy := lock$(p_lock_name);
  end lock$;
  
  procedure unlock(
    p_lock_name varchar2
  ) is
    l_lock_handle varchar2(50);
    l_dummy integer;
  begin
    
    dbms_lock.allocate_unique(
      lockname        => p_lock_name,
      lockhandle      => l_lock_handle
    );
    
    l_dummy := dbms_lock.release(l_lock_handle);
    
  end unlock;
  
  procedure update_action(
    p_action_row in out nocopy g_actions_cur%rowtype
  ) is
    pragma autonomous_transaction;
    l_error_msg varchar2(4000);
  begin
    if p_action_row.status = GC_STS_ERROR then
      l_error_msg := get_error_msg;
    end if;
    
    update pdb_actions a
    set    a.status = p_action_row.status,
           a.critical = p_action_row.critical,
           a.result = l_error_msg,
           a.updated_at = systimestamp,
           a.start_process = nvl(p_action_row.start_process, a.start_process),
           a.end_process = nvl(p_action_row.end_process, a.end_process)
    where  a.id = p_action_row.id;
    
    commit;
  exception
    when others then
      rollback;
      fix_exception($$PLSQL_LINE, 'update_action(id=' || p_action_row.id || ') failed');
      raise;
  end update_action;
  
  procedure process_action(
    p_action_row in out nocopy g_actions_cur%rowtype
  ) is
    e_unknown_action exception;
  begin
    p_action_row.status := GC_STS_PROCESS;
    p_action_row.start_process := systimestamp;
    update_action(p_action_row);
    case 
      when p_action_row.action = GC_ACT_REFRESH then
        pdb_api.refresh_pdbs(p_action_row.pdb_parent);
      when p_action_row.action = GC_ACT_CLONE then
        
        if is_exists_pdb(p_action_row.pdb_name) then
          fix_exception($$PLSQL_LINE, 'process_action failed: PDB "' || p_action_row.pdb_name || '" already exists');
          raise program_error;
        end if;
      
        put_log('create ' || p_action_row.pdb_name || ' from ' || p_action_row.pdb_parent || ' snapshot copy');

        open_ro_pdb(
          p_pdb_name => p_action_row.pdb_parent,
          p_force    => true
        );
        
        clone_pdb(
          p_pdb_source => p_action_row.pdb_parent,
          p_pdb_target => p_action_row.pdb_name,
          p_pdb_path   => p_action_row.pdb_path
        );
        /*на SV084 не нужно
        if is_clone_pdb(p_action_row.pdb_parent) then
          clone_of_clone_pdb(
            p_pdb_source => p_action_row.pdb_parent,
            p_pdb_target => p_action_row.pdb_name
          );
        else
          clone_pdb(
            p_pdb_source => p_action_row.pdb_parent,
            p_pdb_target => p_action_row.pdb_name,
            p_pdb_path   => p_action_row.pdb_path
          );
        end if;
        */
        open_pdb(p_action_row.pdb_name);
        
      when p_action_row.action = GC_ACT_CLOSE then
        close_pdb(
          p_pdb_name => p_action_row.pdb_name
        );
        
      when p_action_row.action = GC_ACT_OPEN then
        open_pdb(
          p_pdb_name => p_action_row.pdb_name
        );
        
      when p_action_row.action = GC_ACT_OPEN_RO then
        open_ro_pdb(
          p_pdb_name => p_action_row.pdb_name
        );
        
      when p_action_row.action = GC_ACT_DROP then
        --
        if is_exists_child(p_action_row.pdb_name) then
          fix_exception($$PLSQL_LINE, '.process_action(drop, ' || p_action_row.pdb_name || ') is rejected, found exists children(s) PDB');
          raise program_error;
        end if;
        --
        if not is_exists_pdb(p_action_row.pdb_name) then
          fix_exception($$PLSQL_LINE, 'process_action: drop PDB ' || p_action_row.pdb_name || ' failed. PDB not found.');
          raise program_error;
        end if;
        --
        close_pdb(
          p_pdb_name => p_action_row.pdb_name,
          p_force    => true
        );
        --
        drop_pdb(
          p_pdb_name => p_action_row.pdb_name
        );
          /*на SV084 не нужно
        if is_clone_of_clone_pdb(p_action_row.pdb_name) then
          drop_clone_pdb(
            p_pdb_name => p_action_row.pdb_name
          );
        else
          drop_pdb(
            p_pdb_name => p_action_row.pdb_name
          );
        end if;--*/
      else
        fix_exception($$PLSQL_LINE, 'process_action: Unknown action "' || p_action_row.action || '"');--p_action_row.status := GC_STS_UNKNOWN;
        raise program_error;
    end case;
    p_action_row.status := case when p_action_row.status <> GC_STS_UNKNOWN then GC_STS_SUCCESS else p_action_row.status end;
    p_action_row.end_process := systimestamp;
    update_action(p_action_row);
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'process_action(' || p_action_row.action || ',' || p_action_row.pdb_name || ', ' || p_action_row.pdb_parent || ') failed.');
      p_action_row.status := GC_STS_ERROR;
      p_action_row.critical := case when is_critical_error then 'Y' else 'N' end;
      update_action(p_action_row);
      raise;
  end process_action;
  
  procedure set_daemon_state(
    p_daemon_id int,
    p_status    varchar2,
    p_state     varchar2
  ) is
    pragma autonomous_transaction;
  begin
    update pdb_daemon d
    set    d.status = p_status,
           d.state  = nvl(p_state, d.state),
           d.last_execute = systimestamp,
           d.stop_time = case when p_status = GC_STS_DM_STOP then current_timestamp else d.stop_time end
    where  d.id = p_daemon_id;
    commit;
  exception
    when others then
      rollback;
      fix_exception($$PLSQL_LINE, 'set_daemon_state failed');
  end set_daemon_state;
  
  procedure update_daemon_last_execute(
    p_daemon_id int
  ) is
    pragma autonomous_transaction;
  begin
    update pdb_daemon d
    set    d.last_execute = current_timestamp
    where  d.id = p_daemon_id;
    commit;
  exception
    when others then
      rollback;
      fix_exception($$PLSQL_LINE, 'update_daemon_last_execute failed');
  end update_daemon_last_execute;
  
  procedure update_pdb_clones is
    pragma autonomous_transaction;
    
    type l_pdb_rec_typ is record (
      pdb_name varchar2(32),
      pdb_mode varchar2(10),
      new_mode varchar2(10),
      creation_time date
    );
    type l_pdbs_tbl_typ is table of l_pdb_rec_typ;
    
    l_pdbs l_pdbs_tbl_typ;
  begin
    
    select cp.pdb_name,
           cp.open_mode, 
           nvl(p.open_mode, GC_PDB_NOT_EXISTS),
           scn_to_date(p.CREATE_SCN) CREATION_TIME
    bulk collect into l_pdbs
    from   pdb_clones cp,
           v$pdbs     p
    where  1=1
    and    p.name(+) = cp.pdb_name;
    
    for i in 1..l_pdbs.count loop
      if nvl(l_pdbs(i).pdb_mode, '#') <> nvl(l_pdbs(i).new_mode, '##') then
        update pdb_clones cp
        set    cp.last_open_mode = case 
                                     when cp.last_open_mode is null and l_pdbs(i).new_mode <> GC_PDB_NOT_EXISTS then
                                       l_pdbs(i).new_mode
                                     else
                                       cp.last_open_mode
                                   end,
               cp.open_mode      = l_pdbs(i).new_mode,
               cp.pdb_created    = case
                                     when l_pdbs(i).creation_time is null or l_pdbs(i).pdb_mode = 'GC_PDB_NOT_EXISTS' then
                                       cp.pdb_created
                                     else l_pdbs(i).creation_time
                                   end
        where  cp.pdb_name = l_pdbs(i).pdb_name;
      end if;
    end loop;
    
    commit;
  exception
    when others then
      rollback;
      fix_exception($$PLSQL_LINE, 'update_pdb_clones failed');
  end update_pdb_clones;
  
  
  procedure pdb_daemon(
    p_daemon_id int
  ) is
    --
    l_daemon_status varchar2(20);
    --
    function is_stop_ return boolean is
      --
      function is_lock_ return boolean is
      begin
        if lock$(GC_PDB_DAEMON_STOP) <> 0 then
          put_log(GC_PDB_DAEMON || ' stopped via lock ' || GC_PDB_DAEMON_STOP);
          return true;
        end if;
        unlock(GC_PDB_DAEMON_STOP);
        return false;
      end is_lock_;
      --
      function is_stop_ return boolean is
      begin
        select d.status
        into   l_daemon_status
        from   pdb_daemon d
        where  d.id = p_daemon_id;
        --
        return l_daemon_status = GC_STS_DM_STOP;
      exception
        when no_data_found then
          return true;
      end is_stop_;
      --
    begin
      return is_lock_ or is_stop_;
    end is_stop_;
    
    function start_action_ return boolean is
      l_action_row g_actions_cur%rowtype;
    begin
    
      open g_actions_cur;
      fetch g_actions_cur into l_action_row;
      if g_actions_cur%notfound then
        l_action_row.id := null;
      end if;
      close g_actions_cur;
      
      if l_action_row.id is not null then
        begin
          put_log(GC_PDB_DAEMON || ' (' || l_action_row.id || ') ' || l_action_row.action || ' ' || l_action_row.pdb_name || ', ' || l_action_row.pdb_parent);
          process_action(l_action_row);
        exception
          when others then
            if is_critical_error then
              set_daemon_state(
                p_daemon_id => p_daemon_id,
                p_status    => GC_STS_DM_PAUSE,
                p_state     => GC_ST_DM_CRITICAL
              );
              put_log(GC_PDB_DAEMON || ' critical error');
              purge_error;
            end if;
        end;
      end if;
      
      return l_action_row.id is not null;
      
    end start_action_;
    --
  begin
    --
    while(not is_stop_) loop
      purge_error;
      if l_daemon_status = GC_STS_DM_START  then
        update_pdb_clones;
        if not start_action_ then
          dbms_lock.sleep(seconds => GC_TIMEOUT);
        end if;
      end if;
      update_daemon_last_execute(p_daemon_id);
    end loop;
    --
  end pdb_daemon;
  
  procedure start_daemon is
    l_daemon_id int;
    --
    procedure create_daemon_ is
    begin
      --
      update pdb_daemon d
      set    d.status = GC_STS_DM_STOP
      where  d.status <> GC_STS_DM_STOP;
      --
      insert into pdb_daemon(
        status    ,
        state     ,
        start_time
      ) values (
        GC_STS_DM_START,
        GC_ST_DM_NORMAL,
        current_timestamp
      );
      --
      /*
      TODO: owner="V.Zhuravov" created="28.04.2018"
      text="Добавить TABLE API для PDB_DAEMON"
      */
      select id
      into   l_daemon_id
      from   pdb_daemon d
      where  d.status = GC_STS_DM_START
      order by start_time desc, id desc
      fetch first row only;
      --
      commit;
    end create_daemon_;
    --
  begin
    put_log('Start ' || GC_PDB_DAEMON);
    purge_error;
    if lock$(GC_PDB_DAEMON) = 0 then
      create_daemon_;
      put_log('Daemon ID: ' || l_daemon_id);
      pdb_daemon(l_daemon_id);
      unlock(GC_PDB_DAEMON);
    else
      fix_exception($$PLSQL_LINE, 'Start ' || GC_PDB_DAEMON || ' failed. Daemon already running');
      raise program_error;
    end if;
    
    set_daemon_state(
      p_daemon_id => l_daemon_id,
      p_status    => GC_STS_DM_STOP,
      p_state     => null
    );
    
    put_log('End ' || GC_PDB_DAEMON || ' (' || l_daemon_id || ')');
    
  exception
    when others then
      unlock(GC_PDB_DAEMON);
      fix_exception($$PLSQL_LINE, 'Start ' || GC_PDB_DAEMON || ' failed.');
      set_daemon_state(
        p_daemon_id => l_daemon_id,
        p_status    => GC_STS_DM_STOP,
        p_state     => GC_ST_DM_ERROR
      );
      raise;
  end start_daemon;
  
  procedure stop_daemon is
  begin
    dbms_output.enable(100000);
    put_log('Stop ' || GC_PDB_DAEMON);
    if lock$(GC_PDB_DAEMON_STOP) = 0 then
      while lock$(GC_PDB_DAEMON) <> 0 loop
        dbms_lock.sleep(10);
      end loop;
      unlock(GC_PDB_DAEMON);
      unlock(GC_PDB_DAEMON_STOP);
      put_log('Stop ' || GC_PDB_DAEMON || ' succesful');
    end if;
  end stop_daemon;
  
  function scn_to_date(p_scn number) return date is
  begin
    return cast(scn_to_timestamp(p_scn) as date);
  exception
    when others then
      return null;
  end;
  
end pdb_daemon_api;
/
