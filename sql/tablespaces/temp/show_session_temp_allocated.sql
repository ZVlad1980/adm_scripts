with w_sessions as (
  select s.sample_id,
         s.sample_time,
         trunc(s.sample_time) sample_day,
         s.user_id,
         s.program,
         s.module,
         s.action,
         s.machine,
         s.session_id || ',' || s.session_serial# || ' (' || s.session_type || ')' session_info,
         s.sql_id,
         s.sql_child_number,
         s.top_level_sql_id,
         s.sql_opname,
         s.sql_plan_hash_value,
         s.sql_plan_line_id,
         s.sql_exec_id,
         s.sql_exec_start,
         round(s.pga_allocated / 1024 / 1024 / 1024, 3)        pga_allocated,
         round(s.temp_space_allocated / 1024 / 1024 / 1024, 3) temp_space_allocated
  from   gv$active_session_history@pdh_prod s
  where  s.temp_space_allocated > 1024*1024*1024
)
select s.sample_day,
       s.user_id,
       s.program,
       s.module,
       s.action,
       s.machine,
       s.session_info,
       max(pga_allocated)        pga_allocated,
       max(temp_space_allocated) temp_space_allocated
from   w_sessions s
group by s.sample_day,
         s.user_id,
         s.program,
         s.module,
         s.action,
         s.machine,
         s.session_info
order by s.sample_day desc
/
select * from   gv$active_session_history@pdh_prod s
