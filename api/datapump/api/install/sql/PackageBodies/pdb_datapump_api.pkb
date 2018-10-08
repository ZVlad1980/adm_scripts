create or replace package body datapump_api is
  
  GC_UNIT_NAME constant varchar2(32) := $$PLSQL_UNIT;
  
  procedure fix_exception(p_line int, p_message varchar2) is
  begin
    gf_dump_log_api.append_error(
      p_message => GC_UNIT_NAME || ' (' || p_line || '): ' || p_message
    );
  end fix_exception;
  
  /**
   * Функция конвертирует log_entry в одну строку
   */
  function conv_logentry2str(
    p_log_entry ku$_logentry
  ) return varchar2 is
    l_result        varchar2(32767);
    l_ind           number;
  begin
    --
    l_ind := p_log_entry.FIRST;
    while l_ind is not null loop
      l_result := l_result || p_log_entry(l_ind).LogText || chr(10);
      l_ind := p_log_entry.next(l_ind);
    end loop;
    --
    return l_result;
    --
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'get_error_info');
  end conv_logentry2str;
  
  /**
   * Запуск Job + контроль завершения
   */
  procedure start_job(
    p_handle number
  ) is
    l_job_state     varchar2(30);     -- To keep track of job state
    l_job_status    ku$_status;       -- The status object returned by get_status
  begin
    --
    dbms_datapump.start_job(
      handle       => p_handle--,      abort_step => -1
    );
    --
    l_job_state    := 'UNDEFINED';
    while (l_job_state not in ('COMPLETED', 'STOPPED')) loop
      dbms_datapump.get_status(
        handle      => p_handle,
        mask        => dbms_datapump.ku$_status_job_error +
                       dbms_datapump.ku$_status_job_status +
                       dbms_datapump.ku$_status_wip,
        timeout     =>  -1,
        job_state   => l_job_state,
        status      => l_job_status
      );
      
      /*
      TODO: owner="V.Zhuravov" created="14.04.2018"
      text="Восстановить контроль статуса джоба. Отключил, т.к. не отличает warning от error. User FND загружается заблокированным!"
      */
      /*if (bitand(l_job_status.mask, dbms_datapump.ku$_status_job_error) != 0) then
          raise program_error;
      end if;*/
      
      -- If any work-in-progress (WIP) or Error messages were received for the job,
      -- display them.
    
      /*if (bitand(l_job_status.mask, dbms_datapump.ku$_status_wip) != 0) then
        le := l_job_status.wip;
      else
        le := null;
      end if;
      /*if le is not null then
        ind := le.first;
        while ind is not null loop
          plog(le(ind).logtext);
          ind := le.next(ind);
        end loop;
      end if; --*/
      --
      dbms_lock.sleep(5);
    end loop;
    --
  exception
    when program_error then
      fix_exception($$PLSQL_LINE, 'get_error_info: ' || conv_logentry2str(l_job_status.error));
      raise;
    when others then
      fix_exception($$PLSQL_LINE, 'get_error_info');
      raise;
  end start_job;
  
  /**
   * Процедура ремаппинга табличных пространств remap_tablespace
   *
   * @param p_handle    - указатель на datapump процесс
   * @param p_source_ts - имя исходного табл.пространства
   * @param p_target_ts - имя целевого табл.пространства
   *
   */
  procedure remap_tablespace(
    p_handle        number,
    p_source_ts     varchar2,
    p_target_ts     varchar2
  ) is
  begin
    dbms_datapump.metadata_remap(p_handle, 'REMAP_TABLESPACE', p_source_ts, p_target_ts);
    --
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'remap_tablespace');
      raise;
  end remap_tablespace;
  
  /**
   * Процедура исключения загрузки данных таблицы exclude_table_data
   *
   * @param p_handle     - указатель на datapump процесс
   * @param p_schema     - имя схемы
   * @param p_table_name - имя таблицы
   *
   */
  procedure exclude_table_data(
    p_handle        number,
    p_schema        varchar2,
    p_table_name    varchar2
  ) is
  begin
    --
    DBMS_DATAPUMP.DATA_FILTER(p_handle,'INCLUDE_ROWS', 0, p_table_name, p_schema);
    --
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'exclude_table_data: ' || p_schema || '.' || p_table_name);
      raise;
  end exclude_table_data;
  
  /**
   */
  procedure config_import(
    p_handle        number,
    p_schema        varchar2,
    p_directory     varchar2,
    p_dump_file     varchar2,
    p_log_file      varchar2,
    p_config_fn     varchar2, 
    p_only_user     boolean  ,
    p_metadata_only boolean  
  ) is
    --
    /*procedure remap_tablespace_(p_source_ts varchar2) is
    begin
      dbms_datapump.metadata_remap(p_handle, 'REMAP_TABLESPACE', p_source_ts, p_tablespace);
    end ;--*/
    --
  begin
    --
    dbms_datapump.set_parallel(handle => p_handle, degree => 2);
    --
    dbms_datapump.add_file(p_handle, p_dump_file, p_directory, filetype => DBMS_DATAPUMP.KU$_FILE_TYPE_DUMP_FILE);
    dbms_datapump.add_File(p_handle, p_log_file || case when p_only_user then '_USER' end,  p_directory, filetype => DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE);
    --
    if p_only_user then
      DBMS_DATAPUMP.METADATA_FILTER(handle=> p_handle, name => 'INCLUDE_PATH_EXPR', value => '=''SCHEMA_EXPORT/USER''');
    else
      DBMS_DATAPUMP.METADATA_FILTER(handle=> p_handle, name => 'EXCLUDE_PATH_EXPR', value => '=''TABLE_STATISTICS''');
      DBMS_DATAPUMP.METADATA_FILTER(handle=> p_handle, name => 'EXCLUDE_PATH_EXPR', value => '=''INDEX_STATISTICS''');
      if p_metadata_only then
        DBMS_DATAPUMP.DATA_FILTER(p_handle, 'INCLUDE_ROWS', 0, NULL, NULL); --metadataonly
      end if;
    end if;
    --
    if p_config_fn is not null then
      execute immediate 'begin ' || p_config_fn || '(:handle, :schema, :p_metadata_only); end;'
        using p_handle, p_schema, p_metadata_only;
    end if;
    --
    dbms_datapump.metadata_transform(p_handle, 'STORAGE' , 0);
    dbms_datapump.metadata_transform(p_handle, 'DISABLE_ARCHIVE_LOGGING', 0);
    dbms_datapump.metadata_transform(p_handle, 'SEGMENT_ATTRIBUTES', 0);
    --
    dbms_datapump.set_parallel(
      handle => p_handle,
      degree => 6
    );
    --
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'config_import');
      raise;
  end config_import;
    
  /**
   * Процедура импорта схемы import_schema
   *
   * @param p_master_table  - имя мастер таблицы
   * @param p_schema        - имя схемы
   * @param p_directory     - имя объекта DIRECTORY
   * @param p_dump_file     - имя dump файла (или шаблон)
   * @param p_log_file      - имя лог файла (будет в DIRECTORY)
   * @param p_config_fn     - функция для настройки импорта, должна принимать три параметра: p_handle number, p_schema varchar2, p_metadata_only boolean
   * @param p_only_user     - признак загрузки только определения схемы (p_config_fn не вызывается!)
   * @param p_metadata_only - признак загрузки только метаданных
   *
   */
  procedure import_schema(
    p_master_table  varchar2,
    p_schema        varchar2,
    p_directory     varchar2,
    p_dump_file     varchar2,
    p_log_file      varchar2,
    p_config_fn     varchar2       default null,
    p_only_user     boolean        default false,
    p_metadata_only boolean        default false --test mode
  ) is
    l_handle number;
  begin
    --
    l_handle := dbms_datapump.open('IMPORT', 'SCHEMA', null, p_master_table);
    --
    config_import(
      p_handle         => l_handle       ,
      p_schema         => p_schema       ,
      p_directory      => p_directory    ,
      p_dump_file      => p_dump_file    ,
      p_log_file       => p_log_file     ,
      p_config_fn      => p_config_fn    ,
      p_only_user      => p_only_user    ,
      p_metadata_only  => p_metadata_only
    );
    --
    start_job(p_handle => l_handle);
    --
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'import_schema');
      raise;
  end import_schema;
  
end datapump_api;
/
