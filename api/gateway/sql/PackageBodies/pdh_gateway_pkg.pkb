create or replace package body pdh_gateway_pkg is
  
  C_MODULE constant varchar2(30) := 'PDH_GATEWAY';


  /**
   * Only simply JSON: {"a":"b",...,"x":"c"}
   */
  function get_parameters_tbl(
    p_json varchar2
  ) return pdh_gateway_param_tbl_typ
  pipelined is
    c_routine  constant varchar2(30) := 'get_parameters_tbl';
    
    l_row      varchar2(32767);
    l_json     varchar2(32767);
    
    function get_body_(p_json varchar2) return varchar2 is
      l_start int;
    begin 
      l_start := instr(p_json, '{') + 1;
      return 
        trim(
          translate(
            substr(
              p_json, 
              l_start, 
              instr(p_json, '}', -1) - l_start
            ),
            1 || chr(10) || chr(8) || chr(9) || chr(13),
            '1'
          )
        ) || ',';
    end get_body_;
    
    function get_row_(
      p_body   in out nocopy varchar2, 
      x_result in out varchar2
    ) return boolean is
      l_pos int;
    begin
      if p_body is null then
        return false;
      end if;
      
      l_pos := 1;
      loop
        l_pos := instr(p_body, ',', l_pos);
        exit when mod(regexp_count(substr(p_body, 1, l_pos), '"'), 2) = 0 or l_pos = length(p_body) or l_pos < 1;
        l_pos := l_pos + 1;
      end loop;
      
      if l_pos = 0 then
        raise program_error;
      end if;
      
      x_result := substr(p_body, 1, l_pos - 1);
      
      p_body := substr(p_body, length(x_result) + 2);
      
      x_result := trim(x_result);
      
      return x_result is not null;
      
    end get_row_;
    
    function get_name_(
      p_row   varchar2
    ) return varchar2 is
    begin
      return upper(replace(trim(substr(p_row, 1, instr(p_row, ':') - 1)), '"'));
    end get_name_;
    
    function get_value_(
      p_row   varchar2
    ) return varchar2 is
    begin
      return replace(trim(substr(p_row, instr(p_row, ':') + 1)), '"');
    end get_value_;
    
  begin
    logger.start_action(c_routine);
    l_json := get_body_(p_json);
    while get_row_(l_json, l_row) = true loop
      pipe row (pdh_gateway_param_typ(p_name => get_name_(l_row), p_value => get_value_(l_row)));
    end loop;
    
  exception
    when others then
      logger.fail_action(
        p_msg     => 'Parse JSON fail',
        p_unit    => $$PLSQL_UNIT,
        p_routine => c_routine,
        p_line    => $$PLSQL_LINE
      );
      raise;
  end get_parameters_tbl;
  
  /**
   *
   */
  procedure parse_json(
    p_json        varchar2,
    x_parameters  in out nocopy pdh_gateway_params_typ
  ) is
    c_routine constant varchar2(30) := 'parse_json';
  begin
    logger.start_action(c_routine);
    x_parameters  := pdh_gateway_params_typ();
    for p in (
      select p.parameter_name, p.parameter_value
      from   table(get_parameters_tbl(p_json)) p
    ) loop
      logger.debug('ADD: ' || p.parameter_name || ', ' || p.parameter_value);
      x_parameters.add_parameter(
        p_parameter => pdh_gateway_param_typ(
          p_name  => p.parameter_name,
          p_value => p.parameter_value
        )
      );
    end loop;
    logger.end_action;
  exception
    when others then
      logger.fail_action;
      raise;
  end parse_json;
  
  /**
   *
   */
  function get_module(
    p_module varchar2,
    p_action varchar2
  ) return pdh_gateway_module_typ is
    c_routine constant varchar2(30) := 'get_module';
    
    l_result pdh_gateway_module_typ;
  begin
    logger.start_action(c_routine);
    
    select m.module
    into   l_result
    from   pdh_gateway_modules_v m
    where  1=1
    and    m.action_name = p_action
    and    m.module_name = p_module;
    
    logger.end_action;
    
    return l_result;
    
  exception
    when others then
      logger.fail_action(
        p_unit    => $$PLSQL_UNIT,
        p_routine => c_routine,
        p_line    => $$PLSQL_LINE,
        p_params  => sys.odcivarchar2list(
                       'p_module', p_module,
                       'p_action', p_action
                     )
      );
      raise;
  end get_module;
  
  /**
   * 
   */
  procedure run_module(
    p_module varchar2,
    p_action varchar2,
    p_params in out nocopy pdh_gateway_params_typ
  ) is
    c_routine constant varchar2(30) := 'run_module';
    
    function get_command_(
      p_unit  varchar2
    ) return varchar2 is
      l_result varchar2(32767);
      l_name   varchar2(30);
      l_value  varchar2(2048);
    begin
      
      p_params.first;
      while p_params.next(l_name, l_value) loop
        l_result := l_result || case when l_result is not null then ',' end
          || l_name || ' => ''''' || replace(l_value, '''', '''''' || '''');
      end loop;
      
      return 'begin ' || p_unit || case when l_result is not null then '(' || l_result || ')' end || '; end;';
      
    end get_command_;
    
    procedure ei_(
      p_cmd varchar2
    ) is
    begin
      logger.start_action('ei_');
      --logger.out(p_cmd);
      execute immediate p_cmd;
      logger.end_action;
    exception
      when others then
        logger.fail_action(
          p_msg     => 'Dynamic execution fail',
          p_unit    => $$PLSQL_UNIT,
          p_routine => c_routine,
          p_line    => $$PLSQL_LINE,
          p_params  => sys.odcivarchar2list(
                         'p_cmd', p_cmd
                       )
        );
        raise;
    end ei_;

  begin
    
    logger.start_action(c_routine);
    /*
    TODO: owner="vzhuravov" created="11/30/2018"
    text="Create object type UNIT"
    */
    
    ei_(get_module(p_module, p_action).get_launch_cmd(p_params));
    
    logger.end_action;
    
  exception
    when others then
      logger.fail_action(
        p_msg     => c_routine || ' failed',
        p_unit    => $$PLSQL_UNIT,
        p_routine => c_routine,
        p_line    => $$PLSQL_LINE,
        p_params  => sys.odcivarchar2list(
                       'p_module', p_module,
                       'p_action', p_action
                     )
      );
      raise;
  end run_module;
  
  /**
   * Main procedure for launch of PDH modules without retruns of results
   *
   * p_module - name of module
   * p_action - name of action
   * p_json   - list of parameters into JSON,
   * p_commit - commit or not (boolean  default true)
   *
   */
  procedure launch(
    p_module  varchar2 default null,
    p_action  varchar2 default null,
    p_json    varchar2 default null,
    p_commit  boolean  default true
  ) is
    c_routine constant varchar2(30) := 'launch';
    
    l_log_id    int;
    l_params    pdh_gateway_params_typ;
    l_error_msg varchar2(2000);
  begin
    
    logger.start_module(
      p_module => C_MODULE,
      p_action => c_routine
    );
    
    l_log_id := logger.get_log_id;
    logger.out('Run' || logger.new_line
      || 'p_module: ' || p_module || logger.new_line
      || 'p_action: ' || p_action || logger.new_line
      || 'p_json  : ' || p_json   || logger.new_line
    );
    
    parse_json(p_json, l_params);
    
    logger.debug('L_PARAMS: '  || xmltype.createXML(l_params).getclobVal());

    run_module(
      p_module => p_module,
      p_action => p_action,
      p_params => l_params
    );
    
    if p_commit then
      commit;
    end if;
    
    logger.end_module;
    
  exception
    when others then
      
      if p_commit then
        rollback;
      end if;
      
      l_error_msg := logger.get_last_error();
      logger.error(
        p_msg     => 'Gateway Launcher fail',
        p_unit    => $$PLSQL_UNIT,
        p_routine => c_routine,
        p_line    => $$PLSQL_LINE,
        p_params  => sys.odcivarchar2list(
                       'p_module', p_module,
                       'p_action', p_action,
                       'p_json',   p_json  
                     )
      );
      logger.end_module;
      raise_application_error(-20000, nvl(l_error_msg, logger.get_last_error()) || '. For details see LOG_DATA.LOG_ID = ' || l_log_id);

  end launch;

end pdh_gateway_pkg;
/
