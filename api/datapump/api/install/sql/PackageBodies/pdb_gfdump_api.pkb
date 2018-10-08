create or replace package body gfdump_api is
  
  GC_UNIT_NAME    constant varchar2(32) := $$PLSQL_UNIT;
  GC_MASTER_TABLE constant varchar2(32) := 'GFDUMP_MASTER_T';
  GC_TABLESPACE   constant varchar2(32) := 'GFNDDATA';
  
  type gt_schema_rec  is record (
    name      varchar2(32),
    dir       varchar2(32),
    dump_file varchar2(256),
    log_file  varchar2(256),
    exclude_tables_file varchar2(256)
  );
  type gt_schemas_tbl is table of gt_schema_rec;
  
  procedure fix_exception(p_line int, p_message varchar2, p_warning boolean default false) is
  begin
    if p_warning then
      gf_dump_log_api.append_warning(
        p_message => GC_UNIT_NAME || ' (' || p_line || '): ' || p_message
      );
    else
      gf_dump_log_api.append_error(
        p_message => GC_UNIT_NAME || ' (' || p_line || '): ' || p_message
      );
    end if;
  end fix_exception;
  
  procedure plog(p_message varchar2, p_fix boolean default false) is
  begin
    gf_dump_log_api.append_message(
      p_message => p_message
    );
    if p_fix then
      gf_dump_log_api.fix_messages;
    end if;
  end plog;
  
  /**
   */
  procedure ei(
    p_cmd varchar2
  ) is
  begin
    --
    execute immediate p_cmd;
    --
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'ei: ' || p_cmd);
      raise;
  end ei;
  
  /**
   * Удаление схем
   */
  procedure purge_schemas(p_schemas sys.odcivarchar2list) is
  begin
    --
    --ei('ALTER SESSION SET "_ORACLE_SCRIPT"=true');
    --
    for u in (
      select u.username
      from   table(p_schemas) s,
             all_users        u
      where  u.username = s.column_value
    ) loop
      ei('drop user ' || u.username || ' cascade');
    end loop;
    --
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'purge_schemas');
      raise;
  end purge_schemas;
  
  /**
   */
  procedure drop_master_table(
    p_table_name varchar2
  ) is
    l_dummy int;
  begin
    select 1
    into   l_dummy
    from   user_tables t
    where  t.table_name = p_table_name;
    --
    ei('drop table ' || p_table_name);
  exception
    when no_data_found then
      fix_exception($$PLSQL_LINE, 'Master table ' || GC_MASTER_TABLE || ' not found.', true);
    when others then
      fix_exception($$PLSQL_LINE, 'drop_master_table: ' || p_table_name);
      raise;
  end drop_master_table;
  
  /**
   */
  procedure load_exclude_tables(
    p_schema in out nocopy gt_schema_rec
  ) is
    l_tables sys.odcivarchar2list;
    --
    procedure load_tables_ is
      l_file UTL_FILE.FILE_TYPE;
      l_line varchar2(500);
    begin
      begin
        l_file := utl_file.fopen(
          location     => p_schema.dir,
          filename     => p_schema.exclude_tables_file,
          open_mode    => 'r'
        );
      exception
        when others then
          fix_exception($$PLSQL_LINE, 'Exclude tables file: ' || p_schema.dir || '/' || p_schema.exclude_tables_file || ' open failed.', true);
          return;
      end;
      loop
        begin
          utl_file.get_line(
            file   => l_file,
            buffer => l_line
          );
        exception
          when no_data_found then
            exit;
        end;
        l_line := replace(trim(l_line), chr(13), '');
        exit when l_line is null;
        l_tables.extend;
        l_tables(l_tables.count) := l_line;
      end loop;
      --
      utl_file.fclose(l_file);
      --
    exception
      when others then
        fix_exception($$PLSQL_LINE, 'load_file_(' || p_schema.name || ')');
        raise;
    end load_tables_;
    --
    procedure merge_tables_ is
      pragma autonomous_transaction;
    begin
      delete from dp_exclude_tables_t e
      where  e.table_owner = p_schema.name;
      --
      merge into dp_exclude_tables_t e
      using (select upper(p_schema.name)  table_owner,
                    upper(t.column_value) table_name
             from   table(l_tables) t
            ) u
      on    (e.table_owner = u.table_owner and e.table_name = u.table_name)
      when not matched then
        insert (table_owner, table_name)
          values (u.table_owner, u.table_name);
      commit;
    exception
      when others then
        rollback;
        fix_exception($$PLSQL_LINE, 'merge_tables_(' || p_schema.name || ')');
        raise;
    end merge_tables_;
    --
  begin
    l_tables := sys.odcivarchar2list();
    --
    load_tables_;
    --
    merge_tables_;
    --
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'load_exclude_tables(' || p_schema.name || ')');
      raise;
  end load_exclude_tables;
  
  /**
   * подготовка схем (удаление + конфиг)
   */
  procedure prepare_schemas(
    p_schemas     sys.odcivarchar2list,
    x_schemas in out nocopy gt_schemas_tbl
  ) is
  begin
    --
    purge_schemas(p_schemas);
    --
    for i in 1..p_schemas.count loop
      load_exclude_tables(x_schemas(i));
    end loop;
    --
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'prepare_schemas');
      raise;
  end prepare_schemas;
  
  /**
   */
  procedure create_users(p_schemas gt_schemas_tbl) is
  begin
    --
    for i in 1..p_schemas.count loop
      drop_master_table(GC_MASTER_TABLE);
      datapump_api.import_schema(
        p_master_table  => GC_MASTER_TABLE,
        p_schema        => p_schemas(i).name,
        p_directory     => p_schemas(i).dir,
        p_dump_file     => p_schemas(i).dump_file,
        p_log_file      => p_schemas(i).log_file,
        p_config_fn     => GC_UNIT_NAME || '.config_import_schema$',
        p_only_user     => true,
        p_metadata_only => true
      );
      ei('alter user ' || p_schemas(i).name || ' identified by ' || p_schemas(i).name || ' account unlock');
      plog('Create user ' || p_schemas(i).name || ' complete');
    end loop;
    --
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'create_users');
      raise;
  end create_users;
  
  /**
   * Callback процедура настройки импорта схемы
   *
   * @param p_handle        - 
   * @param p_schema        - 
   * @param p_metadata_only - 
   *
   */
  procedure config_import_schema$(
    p_handle         number,
    p_schema         varchar2,
    p_metadata_only  boolean
  ) is
    --
    procedure remap_tablespaces_ is
      l_tablespaces sys.odcivarchar2list := 
        sys.odcivarchar2list(
          'UFNDINDX',
          'UFNDDATA',
          'GFPNINDX',
          'GFPNDATA',
          'GFNDINDX',
          'GFNDDAT2',
          'FONDDATA'
        );
    begin
      --
      for i in 1..l_tablespaces.count loop
        datapump_api.remap_tablespace(
          p_handle    => p_handle,
          p_source_ts => l_tablespaces(i),
          p_target_ts => GC_TABLESPACE
        );
      end loop;
      --
    exception
      when others then
        fix_exception($$PLSQL_LINE, 'remap_tablespaces_');
        raise;
    end remap_tablespaces_;
    --
    procedure exclude_tables_data_ is
    begin
      --
      for t in (
        select distinct et.table_name
        from   dp_exclude_tables_t et
        where  et.table_owner = p_schema
      ) loop
        datapump_api.exclude_table_data(
          p_handle     => p_handle,
          p_schema     => p_schema,
          p_table_name => t.table_name
        );
      end loop;
      --
    exception
      when others then
        fix_exception($$PLSQL_LINE, 'exclude_tables_data_');
        raise;
    end exclude_tables_data_;
    --
  begin
    --
    remap_tablespaces_;
    if not p_metadata_only then
      exclude_tables_data_;
    end if;
    --
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'config_import_schema$');
      raise;
  end config_import_schema$; 
  
  /**
   */
  procedure stop_schema_jobs(
    p_schema varchar2
  ) is
      cursor l_jobs_cur is
        select s.owner, s.job_name
        from   all_scheduler_jobs s
        where  s.enabled = 'TRUE'
        and    s.SCHEDULE_OWNER = p_schema;
  begin
    --
    for job in l_jobs_cur loop
      begin
        dbms_scheduler.disable(name => job.owner || '.' || job.job_name, force => true);
      exception
      when others then
        fix_exception($$PLSQL_LINE, 'Stop jobs ' || job.owner || '.' || job.job_name || ': ' || sqlerrm, true);
      end;
    end loop;
    --
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'stop_schema_jobs');
      raise;
  end stop_schema_jobs;
  /**
   *
   */
  procedure import_schemas(
    p_schemas   gt_schemas_tbl,
    p_mode_test boolean  
  ) is
  begin
    --
    for i in 1..p_schemas.count loop
      drop_master_table(GC_MASTER_TABLE);
      plog('Start import schema ' || p_schemas(i).name, true);
      datapump_api.import_schema(
        p_master_table  => GC_MASTER_TABLE,
        p_schema        => p_schemas(i).name,
        p_directory     => p_schemas(i).dir,
        p_dump_file     => p_schemas(i).dump_file,
        p_log_file      => p_schemas(i).log_file,
        p_config_fn     => GC_UNIT_NAME || '.config_import_schema$',
        p_metadata_only => p_mode_test
      );
      stop_schema_jobs(p_schema => p_schemas(i).name);
      plog('Import schema ' || p_schemas(i).name || ' complete.', true);
    end loop;
    --
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'import_schemas');
      raise;
  end import_schemas;
  
  /**
   * Процедура import запускает импорт схем из файлов dpmp
   *
   * @param p_schemas   - список схем (odcivarchar2list)
   * @param p_date_dump - дата импортированных данных (для определения имен файлов)
   * @param p_mode_test - режим теста (загрузка только метаданных, возможны другие ограничения)
   * @param p_continue  - флаг продолжения загрузки. Пользователи уже созданы, исключения прогружены
   *
   */
  procedure import(
    p_schemas   sys.odcivarchar2list,
    p_date_dump date,
    p_mode_test boolean default false,
    p_continue  boolean default false
  ) is
    l_schemas gt_schemas_tbl;
    --
    procedure prepare_schemas_ is
    begin
      l_schemas := gt_schemas_tbl();
      l_schemas.extend(p_schemas.count);
      for i in 1..p_schemas.count loop
        l_schemas(i).name      := p_schemas(i);
        l_schemas(i).dir       := upper('gfdump_' || l_schemas(i).name || '_dir');
        l_schemas(i).dump_file := lower(l_schemas(i).name) || to_char(p_date_dump, 'yymmdd') || '%U.dpdmp';
        l_schemas(i).log_file  := 'import_' || lower(l_schemas(i).name);
        l_schemas(i).exclude_tables_file := 'exclude_' || lower(l_schemas(i).name) || '.conf';
      end loop;
    end prepare_schemas_;
    --
  begin
    --
    plog('Start import GFDUMP API');
    --
    prepare_schemas_;
    --
    if not p_continue then
      plog('Prepare shemas start', true);
      --
      prepare_schemas(p_schemas, l_schemas);
      --
      plog('Prepare shemas complete', true);
      --
      plog('Create users start', true);
      --
      create_users(l_schemas);
      --
      plog('Create users complete', true);
    end if;
    --
    plog('Import schemas start', true);
    --
    import_schemas(l_schemas, p_mode_test);
    --
    plog('Import GFDUMP API complete');
    --
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'import');
      gf_dump_log_api.fix_messages;
      raise_application_error(-20001, 'GFDUMP API failed. For details see GF_DUMP_LOT_T');
  end import;

end gfdump_api;
/
