select m.sql_text,
       dbms_sqltune.report_sql_monitor(
         sql_id       => m.sql_id,
         type         => 'HTML',
         report_level => 'ALL'
       ) as report
from   v$sql_monitor m
where  m.sid = :sid
and    m.session_serial# = :serial#
order  by 1
