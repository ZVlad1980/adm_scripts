select s.username ,s.status,
       s.sid,
       s.serial# ,
       s.username,
       to_char(logon_time, 'dd.mm.yy hh24:mi:ss') logon_time,
       initcap(status) as status,
       s.sid || ',' || s.serial# sess,
       upper(
           substr(
             s.program,
             instr(s.program, '\', -1) + 1
           )
         ) program,
       osuser,
       event
from   v$session s,
       v$process p
where  1=1--upper(s.username) like upper('%&Username%')
--and    s.status = 'INACTIVE'
and    s.paddr = p.addr
and    p.sPID = 12688
order  by s.LOGON_TIME,
       s.machine,
          s.program
/
SELECT     p.program, p.spid
FROM v$session s, v$process p
WHERE s.paddr = p.addr
AND p.spid = 23338--.sid IN (39)
/
select p.SPID linux_pid,
       vs.service_name,
       vs.osuser,
       vs.username,
       vs.logon_time,
       vs.sid,
       vs.serial#,
       vs.audsid,
       vs.user#,
       vs.process,
       vs.machine,
       vs.port,
       vs.terminal,
       vs.program,
       vs.module,
       vs.type,
       vs.status,
       vs.server,
       vs.schemaname,
       vs.sql_id,
       vs.sql_child_number,
       vs.sql_exec_start,
       vs.sql_exec_id,
       vs.prev_sql_addr,
       vs.prev_hash_value,
       vs.prev_sql_id,
       vs.prev_child_number,
       vs.prev_exec_start,
       vs.prev_exec_id,
       vs.blocking_session_status,
       vs.blocking_instance,
       vs.blocking_session,
       vs.final_blocking_session_status,
       vs.final_blocking_instance,
       vs.final_blocking_session,
       vs.event#,
       vs.event,
       vs.state,
       vs.SECONDS_IN_WAIT,
       vs.wait_time,
       vs.wait_time_micro,
       vs.time_remaining_micro,
       vs.time_since_last_wait_micro,
       vs.con_id,
       vs.sql_address,
       vs.sql_hash_value,
       round(vs.pga_tunable_mem /1024/1024, 3)  pga_tunable_mem,
       round(p.PGA_USED_MEM     /1024/1024, 3)  PGA_USED_MEM    ,
       round(p.PGA_ALLOC_MEM    /1024/1024, 3)  PGA_ALLOC_MEM   ,
       round(p.PGA_FREEABLE_MEM /1024/1024, 3)  PGA_FREEABLE_MEM,
       round(p.PGA_MAX_MEM      /1024/1024, 3)  PGA_MAX_MEM     ,
       p.TRACEFILE
from   v$session vs,
       v$process p
where  p.ADDR(+) = vs.PADDR
and    vs.username is not null and vs.status = 'ACTIVE'
order by vs.logon_time, vs.sid
/
select p.SPID linux_pid,
       vs.service_name,
       vs.osuser,
       vs.username,
       vs.logon_time,
       vs.sid,
       vs.serial#,
       vs.audsid,
       vs.user#,
       vs.process,
       vs.machine,
       vs.port,
       vs.terminal,
       vs.program,
       vs.module,
       vs.type,
       vs.status,
       vs.server,
       vs.schemaname,
       vs.sql_id,
       vs.sql_child_number,
       vs.sql_exec_start,
       vs.sql_exec_id,
       vs.prev_sql_addr,
       vs.prev_hash_value,
       vs.prev_sql_id,
       vs.prev_child_number,
       vs.prev_exec_start,
       vs.prev_exec_id,
       vs.blocking_session_status,
       vs.blocking_instance,
       vs.blocking_session,
       vs.final_blocking_session_status,
       vs.final_blocking_instance,
       vs.final_blocking_session,
       vs.event#,
       vs.event,
       vs.state,
       vs.SECONDS_IN_WAIT,
       vs.wait_time,
       vs.wait_time_micro,
       vs.time_remaining_micro,
       vs.time_since_last_wait_micro,
       vs.con_id,
       vs.sql_address,
       vs.sql_hash_value,
       round(vs.pga_tunable_mem /1024/1024, 3)  pga_tunable_mem,
       round(p.PGA_USED_MEM     /1024/1024, 3)  PGA_USED_MEM    ,
       round(p.PGA_ALLOC_MEM    /1024/1024, 3)  PGA_ALLOC_MEM   ,
       round(p.PGA_FREEABLE_MEM /1024/1024, 3)  PGA_FREEABLE_MEM,
       round(p.PGA_MAX_MEM      /1024/1024, 3)  PGA_MAX_MEM     ,
       p.TRACEFILE
from   v$session vs,
       v$process p
where  p.ADDR(+) = vs.PADDR
order by vs.logon_time, vs.sid
/
select m.sql_text, dbms_sqltune.report_sql_monitor(sql_id => m.sql_id, type => /*'ACTIVE'*/'HTML', report_level => 'ALL') AS report
from  v$sql_monitor m
where m.sid = :sid and m.session_serial# = :serial#
order by 1
/
select names.name, stats.statistic#, stats.value
from v$sesstat stats, v$statname names
where stats.sid = :sid
and names.Statistic# = stats.Statistic#
order by stats.statistic#
/
select sql_text from v$sqltext_with_newlines
where address = hextoraw(:sql_address)
and hash_value = :sql_hash_value
order by piece
/* concatenate */
/
select * from v$open_cursor where sid = :sid
/
select l.type,
       case l.type
         when 'TM' then 'DML enqueue'
         when 'TX' then 'Transaction enqueue'
         when 'UL' then 'User supplied'
         else           'System type'
       end      lock_type,
       case l.lmode
         when 0 then 'none'
         when 1 then 'null (NULL)'
         when 2 then 'row-S (SS)'
         when 3 then 'row-X (SX)'
         when 4 then 'share (S)'
         when 5 then 'S/Row-X (SSX)'
         when 6 then 'exclusive (X)'
         else        'unknown: ' || l.lmode
       end       lock_mode,
       l.id1,
       l.id2,
       case l.request --Lock mode in which the process requests the lock
        when 0 then 'none'
        when 1 then 'null (NULL)'
        when 2 then 'row-S (SS)'
        when 3 then 'row-X (SX)'
        when 4 then 'share (S)'
        when 5 then 'S/Row-X (SSX)'
        when 6 then 'exclusive (X)'
        else        'unknown: ' || l.request
       end      request,
       o.object_type,
       o.owner || '.' || o.object_name object_name
from   sys.all_objects o,
       v$lock          l
where  1=1
and    l.type in ('TM', 'TX', 'UL')
and    o.object_id = l.id1
and    l.sid = :sid
/