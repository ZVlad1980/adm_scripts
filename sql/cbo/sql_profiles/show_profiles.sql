--DBMS_SQLTUNE.ACCEPT_SQL_PROFILE
/*tunning advisor
DECLARE
  my_sqlprofile_name VARCHAR2(30);
BEGIN
  my_sqlprofile_name := DBMS_SQLTUNE.ACCEPT_SQL_PROFILE ( 
    task_name    => 'STA_SPECIFIC_EMP_TASK'
,   name         => 'my_sql_profile'
,   profile_type => DBMS_SQLTUNE.PX_PROFILE
,   force_match  => true 
);
END;
/
*/
SELECT *
FROM   DBA_SQL_PROFILES;
/
SELECT *--TASK_ID, TASK_NAME, STATUS, STATUS_MESSAGE
FROM   dba_ADVISOR_LOG
