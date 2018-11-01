SELECT PLAN_TABLE_OUTPUT
FROM   V$SQL s, DBA_SQL_PLAN_BASELINES b, 
       TABLE(
       DBMS_XPLAN.DISPLAY_SQL_PLAN_BASELINE(b.sql_handle,b.plan_name,'basic') 
       ) t
WHERE  s.EXACT_MATCHING_SIGNATURE=b.SIGNATURE
AND    b.PLAN_NAME=s.SQL_PLAN_BASELINE
AND    s.SQL_ID='31d96zzzpcys9';
/
select PLAN_TABLE_OUTPUT
from   dba_sql_plan_baselines b,
       TABLE(
         DBMS_XPLAN.DISPLAY_SQL_PLAN_BASELINE(
           b.sql_handle,
           b.plan_name, 
           'basic'
         ) 
       ) t
where  1=1
and    sql_text like 'SELECT job_title%'
