create or replace package logger_pub is

  -- Author  : Zhuravov
  -- Created : 12/7/2018 9:05:20 AM
  -- Purpose : Public Logger API
  
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
    p_channels   number default null,
    p_msg_level  number default null
  );
  
  procedure start_module(
    p_module varchar2,
    p_action varchar2 default 'main'
  );
  
  procedure end_module;
  
  procedure start_action(
    p_action varchar2
  );
  
  procedure end_action;
  
  procedure fail_subaction(
    p_msg        varchar2             default null,
    p_unit       varchar2             default null,
    p_routine    varchar2             default null,
    p_line       int                  default null,
    p_params     sys.odcivarchar2list default null
  );
  
  procedure fail_action(
    p_msg        varchar2             default null,
    p_unit       varchar2             default null,
    p_routine    varchar2             default null,
    p_line       int                  default null,
    p_params     sys.odcivarchar2list default null
  );
  
  procedure out(
    p_msg varchar2
  );
  
  procedure out(
    p_level number,
    p_msg varchar2
  );
  
  procedure error(
    p_msg        varchar2,
    p_unit       varchar2             default null,
    p_routine    varchar2             default null,
    p_line       int                  default null,
    p_params     sys.odcivarchar2list default null
  );
  
  procedure debug(
   p_msg varchar2 
  );
  
  procedure warn(
    p_msg        varchar2,
    p_unit       varchar2             default null,
    p_routine    varchar2             default null,
    p_line       int                  default null,
    p_params     sys.odcivarchar2list default null
  );
  
  procedure purge_exception;
  
  procedure fix_exception(
    p_msg        varchar2,
    p_unit       varchar2             default null,
    p_routine    varchar2             default null,
    p_line       int                  default null,
    p_params     sys.odcivarchar2list default null
  );
  
  function get_error return varchar2;
  
  function get_last_error return varchar2;
  
  procedure get_error_clob(
    x_error in out nocopy clob
  );
  
  procedure get_last_error_clob(
    x_error in out nocopy clob
  );
  
  function get_state return number;
  
  function get_state_desc return varchar2;
  
  function get_log_id return number;
  
  function conv(
    p_date date
  ) return varchar2;
  
end logger_pub;
/
