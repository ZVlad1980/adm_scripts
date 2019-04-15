select sm.dbop_name,
       sm.dbop_exec_id,
       sm.sql_id, --primary key
       sm.sql_id,
       sm.sql_exec_start,
       sm.sql_exec_id, --this unique key for query
       sm.*
from   v$sql_monitor sm
/
