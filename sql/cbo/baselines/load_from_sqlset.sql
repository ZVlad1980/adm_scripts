--https://docs.oracle.com/database/121/TGSQL/tgsql_sts.htm#TGSQL524
begin
  DBMS_SQLTUNE.create_sqlset(
    sqlset_name  => 'SPM_STS',
    description  => 'Test SQL Tuning Set'
  );
end;
/
select * --NAME, STATEMENT_COUNT AS "SQLCNT", DESCRIPTION
from   user_sqlset;
/
--
--START TEST CURSOR
--
-- Test cursor, set module and action
-- via sqlplus!
begin
  dbms_application_info.set_module('SPM_STS', 'Test SQL Baselines');
end;
/
--Test cursor execute
SELECT /*LOAD_STS*/ *
FROM   sh.sales
WHERE  quantity_sold > 40
ORDER BY prod_id
;
--
--END TEST CURSOR
--
select d.username,
       s.sql_text,
       s.sql_id, --ID parent_cursor
       s.child_number, --if same sql_id in two or more lines
       s.hash_value,
       s.plan_hash_value,
       s.module
from   v$sql     s,
       dba_users d
where  sql_text like '%/*LOAD_STS*/%'
and    sql_text not like '%SQL_TEXT%'
and    d.user_id = s.parsing_user_id
order by s.sql_id, s.child_number
;
DECLARE
  c_sqlarea_cursor DBMS_SQLTUNE.SQLSET_CURSOR;
BEGIN
 OPEN c_sqlarea_cursor FOR
   SELECT VALUE(p)
   FROM   TABLE( 
            DBMS_SQLTUNE.SELECT_CURSOR_CACHE( --see example_select_cursor_chache.sql
            ' sql_text like ''%/*LOAD_STS*/%'' '
           )
          ) p;
-- load the tuning set
  DBMS_SQLTUNE.LOAD_SQLSET (  
    sqlset_name     => 'SPM_STS'
,   populate_cursor =>  c_sqlarea_cursor 
);
END;
/
SELECT *
       --SQL_ID, PARSING_SCHEMA_NAME AS "SCH", SQL_TEXT, ELAPSED_TIME AS "ELAPSED", BUFFER_GETS
FROM   TABLE(DBMS_SQLTUNE.SELECT_SQLSET(
         'SPM_STS'
         --,'buffer_gets >= 200' 
       ));
/
SELECT *
FROM   DBA_SQLSET_STATEMENTS
WHERE  SQLSET_NAME = 'SPM_STS'
and    plan_hash_value=3803407550;
/
declare
  v_plan_cnt number;
begin
  v_plan_cnt := DBMS_SPM.LOAD_PLANS_FROM_SQLSET(
    sqlset_name  => 'SPM_STS',
    basic_filter => 'sql_text like ''SELECT /*LOAD_STS*/%'' and plan_hash_value=3803407550 ' 
  );
end;
/
SELECT *
FROM   DBA_SQL_PLAN_BASELINES
where sql_text like 'SELECT /*LOAD_STS*/%'
;
