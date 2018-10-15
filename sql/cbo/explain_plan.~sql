/*
https://docs.oracle.com/database/121/TGSQL/tgsql_genplan.htm#TGSQL94706

@$ORACLE_HOME/rdbms/admin/UTLXPLS.SQL
@$ORACLE_HOME/rdbms/admin/UTLXPLP.SQL
*/
explain plan for 
  select dep.department_name, emp.first_name, emp.hire_date
  from   hr.employees emp,
         hr.departments dep
  where  1=1
  and    emp.department_id = dep.department_id
  and    dep.department_id = 10
;
--select * from table(dbms_xplan.display);
--view only sqlplus!
--select * from table(DBMS_XPLAN.display_cursor(FORMAT => 'ADAPTIVE'));
set markup html preformat on
select plan_table_output from table(dbms_xplan.display('plan_table',null,'serial'))
;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(FORMAT=>'+ALLSTATS'));
/*
SQLPLUS
set autotrace traceonly <explain|statistics>
select ...
*/
--@/ora1/12_1_0/rdbms/admin/utlxplan.sql - создает таблицу plan_table в схеме.

--select * from plan_table
--/
--select * from table(dbms_xplan.display_cursor(sql_id => ))
