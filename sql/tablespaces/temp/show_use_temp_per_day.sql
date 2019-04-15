/*
https://paulstuartoracle.wordpress.com/2014/07/20/analysing-temp-space-usage-with-ash-data/
column max_temp_per_day_mb format 999,999,999;
column temp_max_size_mb format 999,999,999;
column temp_mb format 999,999,999.9
*/
--define DAYS_AGO=40
with
pivot1 as (
  select min(snap_id) AS begin_snap_id
  from dba_hist_snapshot
  where trunc( begin_interval_time, 'DD')  > trunc(sysdate - &DAYS_AGO, 'DD')
),
pivot2 as (
  select trunc(ash.sample_time, 'MI') sample_time,
         ash.session_id,
         ash.session_serial#,
         ash.sql_id,
         ash.sql_exec_id,
         u.temporary_tablespace,
         max(temp_space_allocated) / (1024 * 1024) max_temp_per_sql_mb
  from   dba_hist_active_sess_history ash
  inner  join dba_users u
  on     ash.user_id = u.user_id
  where  ash.session_type = 'FOREGROUND'
  and    ash.temp_space_allocated > 0
        -- and U.temporary_tablespace = 'TEMP3'
  and    snap_id > (select begin_snap_id
                    from   pivot1)
  group  by trunc(ash.sample_time, 'MI'),
            ash.session_id,
            ash.session_serial#,
            ash.sql_id,
            ash.sql_exec_id,
            u.temporary_tablespace
),
pivot3 as(
  select temporary_tablespace,
         sample_time,
         sum(max_temp_per_sql_mb) total_temp_permin_mb
  from   pivot2
  group  by temporary_tablespace,
            sample_time
  order  by temporary_tablespace,
            sample_time
)
select temporary_tablespace,
       dd.tablespace_size / (1024 * 1024) temp_max_size_mb,
       trunc(sample_time, 'DD') as day,
       max(total_temp_permin_mb) max_temp_per_day_mb
from   pivot3
inner  join dba_temp_free_space dd
on     dd.tablespace_name = pivot3.temporary_tablespace
group  by temporary_tablespace,
          dd.tablespace_size / (1024 * 1024),
          trunc(sample_time, 'DD')
--having trunc(sample_time, 'DD') &gt; to_date('01-11-13', 'DD-MM-YY')
order  by temporary_tablespace,
          day;
