--https://docs.oracle.com/database/121/TGSQL/tgsql_sqlaccess.htm#TGSQL94766
-- conn sh
DROP TABLE user_workload;
CREATE TABLE user_workload
(
  username             varchar2(128),   /* User who executes statement */
  module               varchar2(64),        /* Application module name */
  action               varchar2(64),        /* Application action name */
  elapsed_time         number,               /* Elapsed time for query */
  cpu_time             number,                   /* CPU time for query */
  buffer_gets          number,        /* Buffer gets consumed by query */
  disk_reads           number,         /* Disk reads consumed by query */
  rows_processed       number,         /* # of rows processed by query */
  executions           number,            /* # of times query executed */
  optimizer_cost       number,             /* Optimizer cost for query */
  priority             number,             /* User-priority (1,2 or 3) */
  last_execution_date  date,               /* Last time query executed */
  stat_period          number,          /* Window exec time in seconds */
  sql_text             clob                           /* Full SQL Text */
)
;
-- aggregation with selection
INSERT INTO user_workload (username, module, action, priority, sql_text)
VALUES ('SH', 'Example1', 'Action', 2,
'SELECT   t.week_ending_day, p.prod_subcategory, 
          SUM(s.amount_sold) AS dollars, s.channel_id, s.promo_id
 FROM     sales s, times t, products p 
 WHERE    s.time_id = t.time_id
 AND      s.prod_id = p.prod_id 
 AND      s.prod_id > 10 
 AND      s.prod_id < 50
 GROUP BY t.week_ending_day, p.prod_subcategory, s.channel_id, s.promo_id')
;
-- aggregation with selection
INSERT INTO user_workload (username, module, action, priority, sql_text)
VALUES ('SH', 'Example1', 'Action', 2,
 'SELECT   t.calendar_month_desc, SUM(s.amount_sold) AS dollars
  FROM     sales s , times t
  WHERE    s.time_id = t.time_id
  AND      s.time_id BETWEEN TO_DATE(''01-JAN-2000'', ''DD-MON-YYYY'')
  AND      TO_DATE(''01-JUL-2000'', ''DD-MON-YYYY'')
  GROUP BY t.calendar_month_desc')
/
-- order by
INSERT INTO user_workload (username, module, action, priority, sql_text)
VALUES ('SH', 'Example1', 'Action', 2,
 'SELECT   c.country_id, c.cust_city, c.cust_last_name
  FROM     customers c
  WHERE    c.country_id IN (52790, 52789)
  ORDER BY c.country_id, c.cust_city, c.cust_last_name')
;
COMMIT
;

declare
  workload_name varchar2(255) := 'MY_STS_WORKLOAD';
begin
  dbms_sqltune.create_sqlset(workload_name, 'test purpose');
end;
/
DECLARE
  sqlset_cur DBMS_SQLTUNE.SQLSET_CURSOR;
BEGIN
  OPEN sqlset_cur FOR
    SELECT SQLSET_ROW(null,null, SQL_TEXT, null, null, 'SH', module,
                     'Action', 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, null, 2, 3,
                     sysdate, 0, 0, null, 0, null, null)
    FROM USER_WORKLOAD;
  DBMS_SQLTUNE.LOAD_SQLSET('MY_STS_WORKLOAD', sqlset_cur);
END;
/
select *
from   table(dbms_sqltune.select_sqlset(
         'MY_STS_WORKLOAD'
       ))
;
--
-- Create task advisor path
--
declare
  task_id   number;
  task_name varchar2(255) := 'MYTASK';
begin
  dbms_advisor.create_task('SQL Access Advisor', task_id, task_name);
  dbms_output.put_line(task_id);
  dbms_advisor.set_task_parameter(task_name, 'TIME_LIMIT', 30);
  dbms_advisor.set_task_parameter(task_name, 'ANALYSIS_SCOPE', 'ALL');
  dbms_advisor.add_sts_ref(task_name, 'SH', 'MY_STS_WORKLOAD');
end;
/
select *
from   user_advisor_log log
where  log.task_name = 'MYTASK'
/
begin
  DBMS_ADVISOR.EXECUTE_TASK('MYTASK');
end;
/
select *
from   user_advisor_log log
where  log.task_name = 'MYTASK'
/
--
--Show results
--
select rec_id,
       rank,
       benefit
from   user_advisor_recommendations
where  task_name = 'MYTASK'
order  by rank
;
select sql_id,
       rec_id,
       precost,
       postcost,
       (precost - postcost) * 100 / precost as percent_benefit
from   user_advisor_sqla_wk_stmts
where  task_name = 'MYTASK'
and    workload_name = 'MY_STS_WORKLOAD'
order  by percent_benefit desc
;
select rec_id,
       action_id,
       substr(command, 1, 30) as command
from   user_advisor_actions
where  task_name = 'MYTASK'
order  by rec_id,
          action_id
;

--
-- Full show
--
declare
in_task_name varchar2(32) := 'MYTASK';
  cursor curs is
    select distinct action_id,
                    command,
                    attr1,
                    attr2,
                    attr3,
                    attr4
    from   user_advisor_actions
    where  task_name = in_task_name
    order  by action_id;
  v_action  number;
  v_command varchar2(32);
  v_attr1   varchar2(4000);
  v_attr2   varchar2(4000);
  v_attr3   varchar2(4000);
  v_attr4   varchar2(4000);
  v_attr5   varchar2(4000);
begin
  open curs;
  dbms_output.put_line('=========================================');
  dbms_output.put_line('Task_name = ' || in_task_name);
  loop
    fetch curs
      into v_action,
           v_command,
           v_attr1,
           v_attr2,
           v_attr3,
           v_attr4;
    exit when curs%notfound;
    dbms_output.put_line('Action ID: ' || v_action);
    dbms_output.put_line('Command : ' || v_command);
    dbms_output.put_line('Attr1 (name)      : ' || substr(v_attr1, 1, 30));
    dbms_output.put_line('Attr2 (tablespace): ' || substr(v_attr2, 1, 30));
    dbms_output.put_line('Attr3             : ' || substr(v_attr3, 1, 30));
    dbms_output.put_line('Attr4             : ' || v_attr4);
    dbms_output.put_line('Attr5             : ' || v_attr5);
    dbms_output.put_line('----------------------------------------');
  end loop;
  close curs;
  dbms_output.put_line('=========END RECOMMENDATIONS============');
end show_recm;
/
--SYS!!!
CREATE or REPLACE DIRECTORY ADVISOR_RESULTS AS '/home/oracle/projects/oracle/advisor';
GRANT READ ON DIRECTORY ADVISOR_RESULTS TO PUBLIC;
GRANT WRITE ON DIRECTORY ADVISOR_RESULTS TO PUBLIC;
--
begin
  DBMS_ADVISOR.CREATE_FILE(DBMS_ADVISOR.GET_TASK_SCRIPT('MYTASK'), 'ADVISOR_RESULTS', 'advscript.sql');
end;
/
