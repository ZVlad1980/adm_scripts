select extract(day from snap_interval) * 24 * 60 +
       extract(hour from snap_interval) * 60 +
       extract(minute from snap_interval) snap_interval,
       extract(day from retention) * 24 * 60 +
       extract(hour from retention) * 60 + extract(minute from retention) retention
from   dba_hist_wr_control
/
--all snaphots:
select to_char(s.startup_time, ' DD MON "at" HH24:MI:SS') instart_fmt,
       di.instance_name inst_name,
       di.db_name db_name,
       s.snap_id snap_id,
       to_char(s.end_interval_time, 'DD MON YYYY HH24:MI') snapdat,
       s.snap_level lvl
from   dba_hist_snapshot          s,
       dba_hist_database_instance di here di.dbid = s.dbid and di.instance_number = s.instance_number and di.startup_time = s.startup_time
order  by snap_id
/
select to_char(begin_interval_time, 'hh24') snap_time,
       avg(value) avg_value
from   dba_hist_sysstat natural
join   dba_hist_snapshot
where  stat_name = 'physical reads'
group  by to_char(begin_interval_time, 'hh24')
order  by to_char(begin_interval_time, 'hh24')
/
