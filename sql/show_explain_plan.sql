/*
SQLPLUS
set autotrace traceonly <explain|statistics>
select ...
*/
--@/ora1/12_1_0/rdbms/admin/utlxplan.sql - создает таблицу plan_table в схеме.

explain plan for select * from   t1 where  n1 in (1, 2);
select * from table(dbms_xplan.display);
--select * from plan_table
/
select * from table(dbms_xplan.display_cursor(sql_id => ))
