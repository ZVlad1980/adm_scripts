--https://paulstuartoracle.wordpress.com/2014/07/20/analysing-temp-space-usage-with-ash-data/
--column sum_max_mb format 999,999,999;
--column temporary_tablespace format A20
with pivot1 as
 (select trunc(ash.sample_time, 'MI') sample_time,
         ash.session_id,
         ash.session_serial#,
         ash.sql_id,
         ash.sql_exec_id,
         u.temporary_tablespace,
         max(temp_space_allocated) / (1024 * 1024) max_temp_mb
  from   gv$active_session_history ash,
         dba_users                 u
  where  ash.user_id = u.user_id
  and    ash.session_type = 'FOREGROUND'
  and    ash.temp_space_allocated >= 0
  group  by trunc(ash.sample_time, 'MI'),
            ash.session_id,
            ash.session_serial#,
            ash.sql_id,
            ash.sql_exec_id,
            u.temporary_tablespace)
select temporary_tablespace,
       sample_time,
       sum(max_temp_mb) sum_max_mb
from   pivot1
group  by sample_time,
          temporary_tablespace
having sum(max_temp_mb) > 100
order  by temporary_tablespace,
          sample_time desc;
