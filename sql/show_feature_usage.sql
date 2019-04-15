/*
select
   display_value
from
   v$parameter
where
   name = 'control_management_pack_access';
*/
select 
   name              c1, 
   detected_usages   c2, 
   last_usage_date   c3
from 
   dba_feature_usage_statistics
where 
name in (
 'ADDM', 
 'Automatic SQL Tuning Advisor', 
 'Automatic Workload Repository', 
 'AWR Baseline', 
 'AWR Baseline Template', 
 'AWR Report', 
 'EM Performance Page', 
 'Real-Time SQL Monitoring', 
 'SQL Access Advisor', 
 'SQL Monitoring and Tuning pages', 
 'SQL Performance Analyzer', 
 'SQL Tuning Advisor', 
 'SQL Tuning Set (system)', 
 'SQL Tuning Set (user)'
)
order by name;
