create or replace package tts_api authid current_user is

  -- Author  : V.ZHURAVOV
  -- Created : 02.06.2018 9:47:06
  -- Purpose : Поготовка транспортировки БД и восстановление после
  
  /**
   * Процедура подготовки БД к транспортировке
   *  Вызывать нужно от пользователя system!
   *  
   *  1. формирует список инвалидов
   *  2. преобразует колонки таблиц из XMLTYPE в CLOB 
   *  3. формирует список функциональных индексов с DDL (для воссоздания после переноса)
   *  4. заменяет некорректные дефолтные значения колонок в таблицах (как правило date)
   *
   */
  procedure prepare_transport_db(
    x_status    out varchar2,
    x_error_msg out varchar2
  );
  
  /**
   */
  procedure repair_db(
    x_status    out varchar2,
    x_error_msg out varchar2
  );
  
end tts_api;
/
