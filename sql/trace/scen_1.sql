exec dbms_application_info.set_module('SQLPLUS', 'TABLE_SCAN');
alter session set sql_trace=true;
select * from t1 where n1 in (1, 2);
alter session set sql_trace=false;
