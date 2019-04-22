create or replace package logger_api is

  -- Author  : FLYING
  -- Created : 12/7/2018 11:02:10 AM
  -- Purpose : Core of API Logger
  
  GC_LVL_DEBUG    constant integer := logger_def.GC_LVL_DEBUG;
  GC_LVL_WARNING  constant integer := logger_def.GC_LVL_WARNING;
  GC_LVL_INFO     constant integer := logger_def.GC_LVL_INFO;
  GC_LVL_ERROR    constant integer := logger_def.GC_LVL_ERROR;
  
  GC_CH_LOG    constant integer := logger_def.GC_CH_LOG;
  GC_CH_OUTPUT constant integer := logger_def.GC_CH_OUTPUT;
  GC_CH_BOTH   constant integer := logger_def.GC_CH_BOTH;
  
  new_line   varchar2(1)  := logger_def.new_line;
  delim_line varchar2(30) := logger_def.delim_line;
  
  procedure set_session(
    p_channels   number,
    p_msg_level  number
  );
  
  procedure create_module(
    p_name varchar2
  );
  
  procedure del_module;
  
  procedure start_action(
    p_name varchar2
  );
  
  procedure end_action;
  
  procedure purge_exception;
  
  procedure fix_exception(
    p_msg      varchar2             default null,
    p_unit     varchar2             default null,
    p_routine  varchar2             default null,
    p_line     int                  default null,
    p_params   sys.odcivarchar2list default null
  );
  
  function is_empty_exception return boolean;
  
  procedure out(
    p_level number,
    p_msg   varchar2
  );
  
  function get_error(
    p_last_error boolean default false
  ) return varchar2;
  
  procedure get_error_clob(
    x_error      in out nocopy clob,
    p_last_error boolean default false
  );
  
  procedure set_module_state(
    p_state number
  );
  
  function get_state return number;
  
  function get_log_id return number;
  
  function get_module_name return varchar2;
  
  function get_action_name return varchar2;
  
end logger_api;
/
