create or replace package datapump_api is

  -- Author  : V.ZHURAVOV
  -- Created : 09.04.2018 11:23:27
  -- Purpose : 
  
  -- Public type declarations
  
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
  );
  
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
  );
  
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
  );
  
  procedure start_job(
    p_handle number
  );
  
end datapump_api;
/
