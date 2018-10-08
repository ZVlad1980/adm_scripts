select /*+ gather_plan_statistics*/ 1 from dual;
select * from table(dbms_xplan.display_cursor(null,null,'ALLSTATS LAST'));
