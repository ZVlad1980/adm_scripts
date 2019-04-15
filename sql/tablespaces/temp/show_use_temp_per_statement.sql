/*
https://paulstuartoracle.wordpress.com/2014/07/20/analysing-temp-space-usage-with-ash-data/
COLUMN module format A20
COLUMN sql_opname format A20
COLUMN etime_secs FORMAT 999,999.9
COLUMN etime_mins FORMAT 999,999.9
COLUMN user_id FORMAT 999999
COLUMN sid FORMAT 99999
COLUMN serial# FORMAT 99999
COLUMN username FORMAT A25
COLUMN inst_id FORMAT 99
COLUMN sql_opname FORMAT A10
COLUMN sql_id FORMAT A13
COLUMN sql_exec_id FORMAT 9999999999
COLUMN max_temp_mb FORMAT 999,999,999
COLUMN sql_start_time FORMAT A21
COLUMN sql_end_time FORMAT A21 
*/ 
 
SELECT ASH.inst_id,
  ASH.user_id,
  ASH.session_id sid,
  ASH.session_serial# serial#,
  ASH.sql_id,
  ASH.sql_exec_id,
  ASH.sql_opname,
  ASH.module,
  MIN(sample_time) sql_start_time,
  MAX(sample_time) sql_end_time,
  ((CAST(MAX(sample_time) AS DATE)) - (CAST(MIN(sample_time) AS DATE))) * (3600*24) etime_secs ,
  ((CAST(MAX(sample_time) AS DATE)) - (CAST(MIN(sample_time) AS DATE))) * (60*24) etime_mins ,
  MAX(temp_space_allocated)/(1024*1024) max_temp_mb
FROM gv$active_session_history ASH
WHERE 1=1--ASH.session_type = 'FOREGROUND'
AND ASH.sql_id        IS NOT NULL
AND sample_time BETWEEN to_timestamp('20190410 05:05', 'yyyymmdd hh24:mi') AND to_timestamp('20190410 05:39', 'yyyymmdd hh24:mi')
  --and  ASH.sql_id = &amp;amp;SQL_ID
GROUP BY ASH.inst_id,
  ASH.user_id,
  ASH.session_id,
  ASH.session_serial#,
  ASH.sql_id,
  ASH.sql_opname,
  ASH.sql_exec_id,
  ASH.module
HAVING MAX(temp_space_allocated) > 0;
