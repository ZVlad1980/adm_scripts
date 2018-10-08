create or replace package gf_dump_log_api is

  -- Author  : V.ZHURAVOV
  -- Created : 09.04.2018 10:18:19
  -- Purpose : 
  
  --
  GC_MSG_ERROR   constant varchar2(10) := 'Error';
  GC_MSG_WARNING constant varchar2(10) := 'Warning';
  GC_MSG_MESSAGE constant varchar2(10) := 'Message';
  
  -- Public type declarations
  procedure init;
  
  procedure append_error(
    p_message varchar2
  );
  
  procedure append_warning(
    p_message varchar2
  );
  
  procedure append_message(
    p_message varchar2
  );
  
  procedure fix_messages;
  
  function get_error_detail return clob;
  
  procedure show_messages;
  
end gf_dump_log_api;
/
