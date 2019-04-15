--https://blog.rackspace.com/can-database-runs-temp-space
select s.sid || ',' || s.serial# sid_serial,
       s.username,
       s.osuser,
       p.spid,
       s.module,
       s.program,
       sum(t.blocks) * tbs.block_size / 1024 / 1024 mb_used,
       t.tablespace,
       count(*) sort_ops
from   v$sort_usage    t,
       v$session       s,
       dba_tablespaces tbs,
       v$process       p
where  t.session_addr = s.saddr
and    s.paddr = p.addr
and    t.tablespace = tbs.tablespace_name
group  by s.sid,
          s.serial#,
          s.username,
          s.osuser,
          p.spid,
          s.module,
          s.program,
          tbs.block_size,
          t.tablespace
order  by sid_serial
/
