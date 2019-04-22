create or replace package body log_example_pkg is
  
  C_UNIT constant varchar2(30) := $$PLSQL_UNIT;
  
  procedure sub_process(
    p_code varchar2
  ) is
    c_routine constant varchar2(30) := 'sub_process';
  begin
    logger.out('Sub process start');
    logger.debug('Details sub process');
    
    if p_code = 'WARNING' then
      logger.warn(
        p_msg     => 'Warning! Test message',
        p_unit    => $$PLSQL_UNIT,
        p_routine => c_routine,
        p_line    => $$PLSQL_LINE,
        p_params  => sys.odcivarchar2list(
          'p_code', p_code
        )
      );
    elsif p_code = 'ERROR' then
      raise no_data_found;
    elsif p_code = 'FATAL' then
      raise program_error;
    end if;
    
    logger.debug('Also details sub process');
    logger.out('Sub process complete: ' || logger.get_state_desc);

  exception
    when no_data_found then
      logger.fail_subaction(
        p_msg     => 'Code "' || p_code || '" not found.',
        p_unit    => $$PLSQL_UNIT,
        p_routine => c_routine,
        p_line    => $$PLSQL_LINE,
        p_params  => sys.odcivarchar2list(
          'p_code', p_code
        )
      );
      raise;
    when others then
      logger.fail_subaction(
        p_unit    => $$PLSQL_UNIT,
        p_routine => c_routine,
        p_line    => $$PLSQL_LINE,
        p_params => sys.odcivarchar2list(
          'p_code', p_code
        )
      );
      raise;
  end sub_process;
  
  procedure process(
    p_prodtype_id number,
    p_from_date   date
  ) is
    c_routine constant varchar2(30) := 'process';
  begin
    logger.start_action(
      c_routine
    );
    logger.out('Process start');
    
    sub_process('SUCCESS');
    if p_prodtype_id = 1 then
      sub_process('WARNING');
    elsif p_prodtype_id = 2 then
      sub_process('ERROR');
    elsif p_prodtype_id = 3 then
      sub_process('FATAL');
    end if;
    
    logger.end_action;
  exception
    when others then
      logger.fail_action(
        p_unit     => $$PLSQL_UNIT,
        p_routine  => c_routine,
        p_line    => $$PLSQL_LINE,
        p_params   => sys.odcivarchar2list(
          'p_prodtype_id', p_prodtype_id,
          'p_from_date', logger.conv(p_from_date)
        )
      );
      raise;
  end process;
  
  function get_prodtype_id(
    p_product_code  varchar2
  ) return number is
    c_routine constant varchar2(30) := 'get_prodtype_id';
    l_result number;
  begin
    logger.start_action(
      c_routine
    );
    
    case p_product_code
      when 'BOOK' then
        l_result := 1;
      when 'ARTICLE' then
        l_result := 2;
      when 'JOURNAL' then
        l_result := 3;
    end case;
    
    logger.end_action;
    
    return l_result;
    
  exception
    when others then
      logger.fail_action(
        p_params => sys.odcivarchar2list(
          'p_product_code', p_product_code
        )
      );
      raise;
  end get_prodtype_id;
  
  procedure main(
    p_product_code  varchar2,
    p_from_date     date
  ) is
    c_routine constant varchar2(30) := 'main';
  begin
    
    logger.start_module(
      C_UNIT,
      c_routine
    );
    
    process(
      p_prodtype_id => get_prodtype_id(p_product_code),
      p_from_date   => p_from_date
    );
    
    logger.out('Module ' || C_UNIT || ' complete: ' || logger.get_state_desc);
    
    logger.end_module;
    
  exception
    when others then
      logger.error(
        'Module failed',
        p_unit => C_UNIT,
        p_routine => c_routine,
        p_line    => $$PLSQL_LINE,
        p_params => sys.odcivarchar2list(
          'p_product_code', p_product_code,
          'p_from_date',    logger.conv(p_from_date)
        )
      );
      logger.end_module;
      raise_application_error(-20000, logger.get_error);
  end main;

end log_example_pkg;
/
