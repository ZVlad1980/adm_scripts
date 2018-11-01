/*
https://www.techpaste.com/2012/07/generate-awr-report-oracle-database/

V$ACTIVE_SESSION_HISTORY - Displays the active session history (ASH) sampled every second.
V$METRIC - Displays metric information.
V$METRICNAME - Displays the metrics associated with each metric group.
V$METRIC_HISTORY - Displays historical metrics.
V$METRICGROUP - Displays all metrics groups.
DBA_HIST_ACTIVE_SESS_HISTORY - Displays the history contents of the active session history.
DBA_HIST_BASELINE - Displays baseline information.
DBA_HIST_DATABASE_INSTANCE - Displays database environment information.
DBA_HIST_SNAPSHOT - Displays snapshot information.
DBA_HIST_SQL_PLAN - Displays SQL execution plans.
DBA_HIST_WR_CONTROL - Displays AWR settings.
*/
select *
from   dba_hist_snapshot
/
select *
from   dba_hist_system_event
/
select *
from   dba_hist_sys_time_model
/
select *
from   dba_hist_sqlstat
/
select *
from   dba_hist_osstat
/
select *
from   dba_hist_active_sess_history --online: v$active_session_history
/
