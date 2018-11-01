--https://docs.oracle.com/database/121/TGSQL/tgsql_sts.htm#TGSQL524
begin
  DBMS_SQLTUNE.create_sqlset(
    sqlset_name  => 'NODE_STS',
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
  dbms_application_info.set_module('NODE_STS', 'Test SQL');
end;
/
--Test cursor execute
select emp.*, rowid from   hr.employees emp
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
where  sql_text like '%select emp.*, rowid from   hr.employees emp%'
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
            ' sql_text like ''%select emp.*, rowid from   hr.employees emp%'' and module=''NODE_STS'' '
           )
          ) p;
-- load the tuning set
  DBMS_SQLTUNE.LOAD_SQLSET (  
    sqlset_name     => 'NODE_STS'
,   populate_cursor =>  c_sqlarea_cursor 
);
END;
/
SELECT *
       --SQL_ID, PARSING_SCHEMA_NAME AS "SCH", SQL_TEXT, ELAPSED_TIME AS "ELAPSED", BUFFER_GETS
FROM   TABLE(DBMS_SQLTUNE.SELECT_SQLSET(
         'NODE_STS'
         --,'buffer_gets >= 200' 
       ));
/
--delete not actual
BEGIN
  DBMS_SQLTUNE.DELETE_SQLSET (
      sqlset_name  => 'NODE_STS'
  ,   basic_filter => 'rows_processed < 100'
);
END;
/
SELECT *
       --SQL_ID, PARSING_SCHEMA_NAME AS "SCH", SQL_TEXT, ELAPSED_TIME AS "ELAPSED", BUFFER_GETS
FROM   TABLE(DBMS_SQLTUNE.SELECT_SQLSET(
         'NODE_STS'
        -- ,'buffer_gets >= 200' 
       ));
/
SELECT *
FROM   DBA_SQLSET_STATEMENTS
WHERE  SQLSET_NAME = 'NODE_STS';
