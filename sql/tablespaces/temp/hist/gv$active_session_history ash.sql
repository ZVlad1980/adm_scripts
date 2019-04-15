with w_temp_space_usage as (
  select trunc(sh.sample_time) sample_day,
         sh.user_id,
         sh.program,
         sh.module,
         sh.session_id,
         sh.session_serial#,
         min(sh.sample_time) first_time,
         max(sh.sample_time) last_time,
         round(max(sh.temp_space_allocated) / 1024 / 1024 / 1024, 3) temp_space_allocated
  from   gv$active_session_history@prod_pdh sh
  where  1=1--sh.SAMPLE_TIME > sysdate - 2 -- between sysdate - 2 and sysdate
  and    sh.temp_space_allocated > 50 * 1024 * 1024 * 1024 --more then 1 Gb
  --and    sh.session_id = 779
  --and    sh.session_serial# = 3321
  group by trunc(sh.sample_time),
         sh.user_id,
         sh.program,
         sh.module,
         sh.session_id,
         sh.session_serial#
),
w_temp_space_usage_rest as (
  select su.sample_day,
         su.session_id,
         su.session_serial#,
         count(1) cnt,
         sum(su.temp_space_allocated)temp_space_allocated
  from   (
          select su.sample_day,
                 su.session_id,
                 su.session_serial#,
                 sh.session_id ch_session_id,
                 su.session_serial# ch_session_serial#,
                 round(max(sh.temp_space_allocated) / 1024 / 1024 / 1024, 3)  temp_space_allocated
          from   w_temp_space_usage           su,
                 gv$active_session_history@prod_pdh sh
          where  sh.sample_time between su.first_time and su.last_time
          and    sh.session_id <> su.session_id
          group by su.sample_day,
                   su.session_id,     
                   su.session_serial#,
                   sh.session_id,     
                   sh.session_serial#
        ) su
  group by su.sample_day,
           su.session_id,
           su.session_serial#  
)
select su.sample_day,
       su.user_id,
       su.program,
       su.module,
       su.session_id,
       su.session_serial#,
       su.first_time,
       su.last_time,
       su.temp_space_allocated,
       sur.cnt                   cnt_other_sessions,
       sur.temp_space_allocated  temp_other_sessions
from   w_temp_space_usage      su,
       w_temp_space_usage_rest sur
where  1=1
and    sur.sample_day = su.sample_day
and    sur.session_id = su.session_id
and    sur.session_serial# = su.session_serial#
order by su.sample_day
