create or replace package body logger_api is

  type t_session_type is record(
    msg_level number,
    channels  number,
    log_id    number,
    log_num   number
  );
  g_session t_session_type;
  
  /*type t_message_type is record (
    msg_num   number,
    msg_level number,
    msg       varchar2(4000)
  );
  type t_messages_type is table of t_message_type index by pls_integer;
  */
  type t_action_type is record (
    name       varchar2(64)
  );
  
  type t_actions_type is table of t_action_type index by pls_integer;
  
  type t_module_type is record(
    name    varchar2(64),
    log_id  number,
    log_num number,
    state   number,
    actions t_actions_type
  );
  type t_modules_type is table of t_module_type index by pls_integer;
  
  g_zero_module t_module_type;
  g_modules     t_modules_type;
  
  --Exceptions types
  type t_exception_type is record (
    module_name varchar2(64),
    action_name varchar2(64),
    unit        varchar2(64),
    routine     varchar2(64),
    unit_line   int,
    params      varchar2(2000),
    err_msg     varchar2(2000),
    err_code    number,
    error_stack varchar2(2000),
    backtrace   varchar2(2000),
    call_stack  varchar2(2000)
  );
  type t_exceptions_type is table of t_exception_type index by pls_integer;
  
  g_exceptions      t_exceptions_type;
  g_last_exceptions t_exceptions_type;
  
  procedure get_error_clob(
    x_error      in out nocopy clob,
    p_exceptions t_exceptions_type
  ) is
    
    procedure push_(
      p_exception t_exception_type
    ) is
    begin
      dbms_lob.append(x_error, 'Module: ' || p_exception.module_name || new_line ||
        '  Action:     ' || p_exception.action_name || new_line ||
        '  Routine:    ' || p_exception.unit || 
        case when p_exception.unit is not null or p_exception.routine is not null then '.' end || 
        p_exception.routine || case when p_exception.unit_line is not null then ' (' || p_exception.unit_line || ')' end || new_line ||
        '  Parameters: ' || p_exception.params || new_line ||
        '  Message:    ' || p_exception.err_msg || new_line ||
        '  Code: ' || p_exception.err_code || new_line ||
        delim_line
      );
    end push_;
    
    procedure push_stack_(
      p_exception t_exception_type
    ) is
    begin
      dbms_lob.append(x_error, rpad('-', 30, '-') || new_line ||
        'Error stack: ' || new_line || p_exception.error_stack || new_line ||
        'Error backtrace: ' || new_line || p_exception.backtrace || new_line ||
        'Call stack: ' || new_line || p_exception.call_stack || new_line ||
        delim_line || new_line
      );
    end push_stack_;
  
  begin
    
    for i in 1..p_exceptions.count loop
      push_(p_exceptions(i));
      if i = 1 then
        push_stack_(p_exceptions(i));
      end if;
    end loop;
    
  end get_error_clob;
  
  procedure get_error_clob(
    x_error      in out nocopy clob,
    p_last_error boolean default false
  ) is
  begin
    get_error_clob(
      x_error      => x_error,
      p_exceptions => case when p_last_error then g_last_exceptions else g_exceptions end
    );
  end get_error_clob;
  
  function get_error(
    p_exceptions t_exceptions_type
  ) return varchar2 is
  begin
    return case when p_exceptions.exists(1) then p_exceptions(1).err_msg end;
  end get_error;
  
  function get_error(
    p_last_error boolean default false
  ) return varchar2 is
  begin
    return get_error(case when p_last_error then g_last_exceptions else g_exceptions end);
  end get_error;
  
  procedure set_module_state(
    p_state number
  ) is
  begin
    if g_modules.count > 0 then 
      g_modules(g_modules.count).state := p_state;
    end if;
  end set_module_state;
  
  function get_state return number is
  begin
    return case when g_modules.count > 0 then g_modules(g_modules.count).state end;
  end get_state;
  
  function get_log_id return number is
    l_result number;
  begin
    if g_modules.count > 0 then
      if g_modules(g_modules.count).log_id is null then
        g_modules(g_modules.count).log_id := log_data_sq.nextval();
      end if;
      l_result := g_modules(g_modules.count).log_id;
    else
      if g_session.log_id is null then
        g_session.log_id := log_data_sq.nextval();
      end if;
      l_result := g_session.log_id;
    end if;
    
    return l_result;
    
  end get_log_id;
  
  function next_log_num return number is
    l_result number;
  begin
    if g_modules.count > 0 then 
      l_result := nvl(g_modules(g_modules.count).log_num, 0) + 1;
      g_modules(g_modules.count).log_num := l_result;
    else
      l_result := nvl(g_session.log_num, 0) + 1;
      g_session.log_num := l_result;
    end if;
    
    return l_result;
  
  end next_log_num;
  
  function get_module_name return varchar2 is
  begin
    return case when g_modules.count > 0 then g_modules(g_modules.count).name end;
  end get_module_name;
  
  function get_action_name return varchar2 is
  begin
    return case when g_modules.count > 0 and g_modules(g_modules.count).actions.count > 0 then g_modules(g_modules.count).actions(g_modules(g_modules.count).actions.count).name end;
  end get_action_name;
  
  procedure set_session(
    p_channels   number,
    p_msg_level  number
  ) is
  begin
    g_session.channels  := p_channels;
    g_session.msg_level := p_msg_level;
  end set_session;
  
  procedure set_application(
    p_module t_module_type
  ) is
    l_action varchar2(64);
  begin
    if p_module.actions is not null and p_module.actions.count > 0 then
      l_action := p_module.actions(p_module.actions.count).name;
    else
      l_action := 'NO_ACTION';
    end if;
    
    dbms_application_info.set_module(
      module_name => p_module.name,
      action_name => l_action
    );
    --dbms_lock.sleep(2);
  end set_application;
  
  procedure create_module(
    p_name varchar2
  ) is
    l_module t_module_type;
  begin
    if get_module_name() = p_name then
      return;
    end if;
    
    if g_modules.count = 0 then
      dbms_application_info.read_module(
        module_name => g_zero_module.name,
        action_name => g_zero_module.actions(1).name
      );
    end if;
    
    l_module.name    := p_name;
    l_module.state   := logger_def.GC_ST_SUCCESS;
    if g_modules.count > 0 then
      l_module.log_id  := g_modules(g_modules.count).log_id;
      l_module.log_num := g_modules(g_modules.count).log_num;
    end if;
    g_modules(g_modules.count + 1) := l_module;
    set_application(g_modules(g_modules.count));
  end create_module;
  
  procedure del_module is
  begin
    if g_modules.count > 0 then
      if g_modules.count > 1 and g_modules(g_modules.count - 1).log_id
        = g_modules(g_modules.count).log_id 
      then
        g_modules(g_modules.count - 1).log_num := g_modules(g_modules.count).log_num;
      end if;
      g_modules.delete(g_modules.count);
      if g_modules.count > 0 then
        set_application(g_modules(g_modules.count));
      else
        set_application(g_zero_module);
      end if;
    end if;
  end del_module;
  
  procedure start_action(
    p_name varchar2
  ) is
    l_action t_action_type;
  begin
    if g_modules.count = 0 then
      create_module('Unknown');
    end if;
    
    l_action.name := p_name;
    g_modules(g_modules.count).actions(g_modules(g_modules.count).actions.count + 1) := l_action;
    
    set_application(
      g_modules(g_modules.count)
    );
    
  end start_action;
  
  procedure end_action is
  begin
    if g_modules.count > 0 and g_modules(g_modules.count).actions.count > 0 then
      g_modules(g_modules.count).actions.delete(g_modules(g_modules.count).actions.count);
      set_application(
        g_modules(g_modules.count)
      );
    end if;
  end end_action;
  
  function serializable_parameters(
    p_params   sys.odcivarchar2list
  ) return varchar2 is
    l_result varchar2(2000);
  begin
    if p_params is not null and p_params.count > 0 then
      for i in 1..p_params.count / 2 loop
        l_result := l_result ||
          case when l_result is not null then ', ' end ||
          p_params(i * 2 - 1) || ' => ' || p_params(i * 2);
      end loop;
    end if;
    --
    return l_result;
  end serializable_parameters;
  
  /*
  TODO: owner="flying" created="12/7/2018"
  text="Add get level and channel from options table"
  */
  function get_level return varchar2 is
  begin
    return nvl(g_session.msg_level, GC_LVL_INFO);
  end get_level;
  
  function get_channel return varchar2 is
  begin
    if g_session.channels is null then
      g_session.channels := case when g_modules.count > 0 then GC_CH_LOG else GC_CH_OUTPUT end;
    end if;
    return g_session.channels;
  end get_channel;
  
  function is_active_channel(
    p_channel integer
  ) return boolean is
  begin
    return bitand(get_channel(), p_channel) <> 0;
  end;
  
  function get_level_name(
    p_level number
  ) return varchar2 is
  begin
    return case p_level
      when GC_LVL_DEBUG   then 'DEBUG'
      when GC_LVL_INFO    then 'INFO'
      when GC_LVL_WARNING then 'WARNING'
      when GC_LVL_ERROR   then 'ERROR'
    end;
  end get_level_name;
  
  procedure put_log(
    p_level varchar2,
    p_msg   varchar2,
    p_error in out nocopy clob
  ) is
    pragma autonomous_transaction;
    l_log_id number;
    l_log_num number;
    l_module varchar2(64);
    l_action varchar2(64);
  begin
    if p_msg is null or p_msg = delim_line or g_modules.count = 0 then
      return;
    end if;
    
    l_log_id  := get_log_id();
    l_log_num := next_log_num();
    l_module  := nvl(get_module_name(), 'UNKNOWN');
    l_action  := nvl(get_action_name(), 'UNKNOWN');
    
    insert into log_data(
      log_id,
      log_num,
      module_name,
      action_name,
      message_lvl,
      message,
      error_info,
      created_at
    ) values (
      l_log_id,
      l_log_num,
      l_module,
      l_action,
      p_level,
      p_msg,
      p_error,
      systimestamp
    );
    commit;
  exception
    when others then
      rollback;
      raise;
  end put_log;
  
  procedure output(
    p_level varchar2,
    p_msg   varchar2,
    p_error in out nocopy clob
  ) is
  begin
    if p_msg is not null then
      dbms_output.put(
        '[' || to_char(sysdate, logger_def.GC_FMT_DATE_FULL) || ']' ||
        '[' || p_level || ']: '
      );
    end if;
    dbms_output.put_line(p_msg);
    
    if p_error is not null then
      dbms_output.put_line(p_error);
    end if;
  
  exception
    when others then
      null; --pass error
  end output;
  
  procedure out(
    p_level number,
    p_msg   varchar2
  ) is
    l_error    clob;
    l_level    varchar2(30);
  begin
    
    if p_level < get_level() then
      return;
    end if;
    
    l_level := get_level_name(p_level);
    
    if p_level in (GC_LVL_ERROR, GC_LVL_WARNING) then
      dbms_lob.createtemporary(l_error, true);
      get_error_clob(l_error);
    end if;
    
    if is_active_channel(GC_CH_OUTPUT) then
      output(l_level, p_msg, l_error);
    end if;
    
    if is_active_channel(GC_CH_LOG) then
      put_log(l_level, p_msg, l_error);
    end if;
    
    if l_error is not null then
      dbms_lob.freetemporary(l_error);
    end if;
  end out;
  
  procedure purge_exception is
  begin
    if g_exceptions is not null and g_exceptions.count > 0 then
      g_last_exceptions := g_exceptions;
      g_exceptions.delete();  
    end if;
  end purge_exception;
  
  procedure fix_exception(
    p_msg      varchar2             default null,
    p_unit     varchar2             default null,
    p_routine  varchar2             default null,
    p_line     int                  default null,
    p_params   sys.odcivarchar2list default null
  ) is
    l_exception t_exception_type;
  begin
    l_exception.module_name := get_module_name;
    l_exception.action_name := get_action_name;
    l_exception.unit        := p_unit;
    l_exception.routine     := p_routine;
    l_exception.unit_line   := p_line;
    l_exception.params      := serializable_parameters(p_params);
    l_exception.err_msg     := nvl(p_msg, sqlerrm);
    l_exception.err_code    := sqlcode;
    
    if g_exceptions.count = 0 then
      l_exception.error_stack := dbms_utility.format_error_stack;
      l_exception.call_stack  := dbms_utility.format_call_stack;
      l_exception.backtrace   := dbms_utility.format_error_backtrace;
    end if;
    
    g_exceptions(g_exceptions.count + 1) := l_exception;
  end fix_exception;
  
  function is_empty_exception return boolean is
  begin
    return case when g_exceptions is not null and g_exceptions.count > 0 then false else true end;
  end is_empty_exception;
  
end logger_api;
/
