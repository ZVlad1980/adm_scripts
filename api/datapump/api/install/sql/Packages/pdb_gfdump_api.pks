create or replace package gfdump_api is

  -- Author  : V.ZHURAVOV
  -- Created : 09.04.2018 9:18:13
  -- Purpose : 
  
  -- Public type declarations
  
  /**
   * Callback процедура настройки импорта схемы
   *   Только для внутреннего вызова
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
  );
  
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
  );
  
end gfdump_api;
/
