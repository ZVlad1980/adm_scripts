create or replace package body logger_pub is

  procedure purge_exception is
  begin
    logger_api.purge_exception;
  end purge_exception;
  
  procedure fix_exception(
    p_msg        varchar2,
    p_unit       varchar2             default null,
    p_routine    varchar2             default null,
    p_line       int                  default null,
    p_params     sys.odcivarchar2list default null
  ) is
  begin
    logger_api.fix_exception(
      p_msg       => p_msg,
      p_unit      => p_unit,
      p_routine   => p_routine,
      p_line      => p_line,
      p_params    => p_params
    );
  end fix_exception;
  
  procedure set_session(
    p_channels   number default null,
    p_msg_level  number default null
  ) is
  begin
    logger_api.set_session(
      p_channels  => p_channels,
      p_msg_level => p_msg_level
    );
  end set_session;
  
  procedure start_module(
    p_module varchar2,
    p_action varchar2 default 'main'
  ) is
  begin
    logger_api.create_module(
      p_name => p_module
    );
    logger_api.start_action(
      p_name => p_action
    );
    debug('Start module ' || p_module);
    debug('Start action ' || p_action);
  end start_module;
  
  procedure end_module is
  begin
    debug('Complete module ' || logger_api.get_module_name() || ': ' || get_state_desc());
    if not logger_api.is_empty_exception then
      error(
        p_msg     => 'Missed details of errors when module ended.',
        p_unit    => $$PLSQL_UNIT,
        p_routine => 'end_module',
        p_line    => $$PLSQL_LINE,
        p_params  => sys.odcivarchar2list(
          'MODULE', logger_api.get_module_name,
          'ACTION', logger_api.get_action_name,
          'LOG_ID', logger_api.get_log_id
        )
      );
      logger_api.purge_exception;
    end if;
    logger_api.del_module;
  end end_module;
  
  procedure start_action(
    p_action varchar2
  ) is
  begin
    logger_api.start_action(
      p_name => p_action
    );
    debug('Start action ' || p_action || ' of module ' || logger_api.get_module_name);
  end start_action;
  
  procedure end_action is
  begin
    debug('Complete action ' || logger_api.get_action_name || ' of module ' || logger_api.get_module_name || ': ' || get_state_desc());
    logger_api.end_action;
  end end_action;
  
  procedure fail_subaction(
    p_msg        varchar2             default null,
    p_unit       varchar2             default null,
    p_routine    varchar2             default null,
    p_line       int                  default null,
    p_params     sys.odcivarchar2list default null
  ) is
  begin
    fix_exception(
      p_msg     => p_msg,
      p_unit    => p_unit,
      p_routine => p_routine,
      p_line    => p_line,
      p_params  => p_params
    );
    logger_api.set_module_state(
      p_state => logger_def.GC_ST_ERROR
    );
  end fail_subaction;
  
  procedure fail_action(
    p_msg        varchar2             default null,
    p_unit       varchar2             default null,
    p_routine    varchar2             default null,
    p_line       int                  default null,
    p_params     sys.odcivarchar2list default null
  ) is
  begin
    fail_subaction(
      p_msg     => p_msg     ,
      p_unit    => p_unit    ,
      p_routine => p_routine ,
      p_line    => p_line    ,
      p_params  => p_params  
    );
    debug('Fail action ' || logger_api.get_action_name || ' of module ' || logger_api.get_module_name);
    logger_api.end_action;
  end fail_action;
  
  procedure out(
    p_level number,
    p_msg   varchar2
  ) is
  begin
    logger_api.out(
      p_level => p_level,
      p_msg   => p_msg
    );
  end out;
  
  procedure out(
    p_msg varchar2
  ) is
  begin
    out(GC_LVL_INFO, p_msg);
  end out;
  
  procedure debug(
   p_msg varchar2 
  ) is
  begin
    out(GC_LVL_DEBUG, p_msg);
  end debug;
  
  procedure error(
    p_msg        varchar2,
    p_unit       varchar2             default null,
    p_routine    varchar2             default null,
    p_line       int                  default null,
    p_params     sys.odcivarchar2list default null
  ) is
  begin
    fix_exception(
      p_msg     => p_msg,
      p_unit    => p_unit,
      p_routine => p_routine,
      p_line    => p_line,
      p_params  => p_params
    );
    out(
      p_level     => GC_LVL_ERROR,
      p_msg       => p_msg
    );
    purge_exception;
    logger_api.set_module_state(
      p_state => logger_def.GC_ST_ERROR
    );
  end error;
  
  procedure warn(
    p_msg        varchar2,
    p_unit       varchar2             default null,
    p_routine    varchar2             default null,
    p_line       int                  default null,
    p_params     sys.odcivarchar2list default null
  ) is
  begin
    fix_exception(
      p_msg     => p_msg,
      p_unit    => p_unit,
      p_routine => p_routine,
      p_line    => p_line,
      p_params  => p_params
    );
    out(
      p_level => GC_LVL_WARNING,
      p_msg   => p_msg
    );
    purge_exception;
    logger_api.set_module_state(
      p_state => logger_def.GC_ST_WARNING
    );
  end warn;
  
  function get_error return varchar2 is
  begin
    return logger_api.get_error(p_last_error => false);
  end get_error;
  
  function get_last_error return varchar2 is
  begin
    return logger_api.get_error(p_last_error => true);
  end get_last_error;
  
  procedure get_error_clob(
    x_error in out nocopy clob
  ) is
  begin
    logger_api.get_error_clob(
      x_error      => x_error,
      p_last_error => false
    );
  end get_error_clob;
  
  
  procedure get_last_error_clob(
    x_error in out nocopy clob
  ) is
  begin
    logger_api.get_error_clob(
      x_error      => x_error,
      p_last_error => true
    );
  end get_last_error_clob;
  
  function get_state return number is
  begin
    return logger_api.get_state;
  end get_state;
  
  function get_state_desc return varchar2 is
  begin
    return case logger_api.get_state
      when 0 then 'SUCCESS'
      when 1 then 'WARNING'
      when 2 then 'ERROR'
      else 'UNKNOWN'
    end;
  end get_state_desc;
  
  function conv(
    p_date date
  ) return varchar2
  is 
  begin
    return to_char(p_date, logger_def.GC_FMT_DATE);
  end conv;
  
  function get_log_id return number is
  begin
    return logger_api.get_log_id;
  end get_log_id;
  
end logger_pub;
/
