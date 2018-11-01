/*
config init params:
 OPTIMIZER_CAPTURE_SQL_PLAN_BASELINES = false
  For any repeatable SQL statement that does not already exist in the plan history, the database does not automatically create an initial SQL plan baseline for the statement.
 OPTIMIZER_USE_SQL_PLAN_BASELINES = true
  For any SQL statement that has an existing SQL plan baseline, the database automatically adds new plans to the SQL plan baseline as nonaccepted plans.

Oracle Database PL/SQL Packages and Types Reference (https://docs.oracle.com/database/121/ARPLS/d_spm.htm#ARPLS150)
  to learn more about the DBMS_SPM.LOAD_PLANS_FROM_% functions

The automatic maintenance task SYS_AUTO_SPM_EVOLVE_TASK executes daily in the scheduled maintenance window.  

/
select SQLLOG$
*/
--conn sys
ALTER SYSTEM SET OPTIMIZER_CAPTURE_SQL_PLAN_BASELINES=true
;
SELECT * FROM SQLLOG$
;
SELECT job_title FROM hr.jobs WHERE job_id = 'AD_PRES'
;
SELECT * FROM SQLLOG$
;
SELECT job_title FROM hr.jobs WHERE job_id='PR_REP'
;
SELECT * FROM SQLLOG$
;
--other query
--
select *
from   dba_sql_plan_baselines
where  sql_text like 'SELECT job_title%'
;
--repeate job_id='PR_REP'
SELECT job_title FROM hr.jobs WHERE job_id='PR_REP'
;
select sql_handle,
       sql_text
from   dba_sql_plan_baselines
where  sql_text like 'SELECT job_title%'
;
--
/*
DBMS_XPLAN

DISPLAY_SQL_PLAN_BASELINE
*/
