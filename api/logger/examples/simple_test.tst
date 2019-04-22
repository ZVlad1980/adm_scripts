PL/SQL Developer Test script 3.0
12
begin
  --
  logger.set_session(p_channels => logger.GC_CH_OUTPUT, p_msg_level => logger.GC_LVL_INFO);
  log_example_pkg.main(
    p_product_code => 'BOOK',
    p_from_date    => trunc(sysdate)
  );
exception
  when others then
    dbms_output.put_line(logger.get_error);
    raise;
end;
0
0
