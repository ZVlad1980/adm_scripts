
@/ora1/12_1_0/rdbms/admin/dbmssupp.sql

grant execute on dbms_support to tst
/
grant execute on dbms_monitor to tst
/
begin
  dbms_output.put_line(dbms_monitor.);
end;
