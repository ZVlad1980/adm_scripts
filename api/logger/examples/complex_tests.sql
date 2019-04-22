--Simple test only output
begin
  logger.out('Test');
end;
/
/*
Usage fix_exception
*/
declare 
  l_error clob;
  procedure raise_(p_param varchar2, p_date date) is
  begin
    raise program_error;
  exception
    when others then
      logger.fix_exception(
        p_msg     => 'Fix exception test',
        p_unit    => 'TEST',
        p_routine => 'raise_',
        p_params  => sys.odcivarchar2list(
          'p_param' , p_param,
          'p_date', p_date
        )
      );
      raise;
  end raise_;
begin
  logger.out('Test fix_exception');
  logger.purge_exception;
  raise_('Text', sysdate);
  logger.out('Hide text');
exception
  when others then
    logger.fix_exception(
      p_msg     => 'Test fix_exception'
    );
  dbms_lob.createtemporary(l_error, false);
  logger.get_error_clob(l_error);
  dbms_output.put_line(l_error);
  dbms_lob.freetemporary(l_error);
end;
/
--MODULE
begin dbms_session.reset_package; end;
/
begin
  --
  logger.set_session(
    p_channels  => logger.GC_CH_BOTH,
    p_msg_level => logger.GC_LVL_DEBUG
  );
  
  log_example_pkg.main(
    p_product_code => 'ARTICLE', --'ARTICLE', --'BOOK', --'JOURNAL',
    p_from_date    => trunc(sysdate)
  );
exception
  when others then
    dbms_output.put_line('logger.get_last_error: ' || logger.get_last_error);
    raise;
end;
/
