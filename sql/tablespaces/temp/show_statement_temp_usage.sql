select s.sid || ',' || s.serial# sid_serial,
       s.username,
       t.blocks * tbs.block_size / 1024 / 1024 mb_used,
       t.tablespace,
       t.sqladdr    address,
       q.hash_value,
       q.sql_text
from   v$sort_usage    t,
       v$session       s,
       v$sqlarea       q,
       dba_tablespaces tbs
where  t.session_addr = s.saddr
and    t.sqladdr = q.address(+)
and    t.tablespace = tbs.tablespace_name
order  by s.sid
/
