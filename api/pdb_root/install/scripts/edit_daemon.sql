select t.id, 
       t.status,         --START - работает
       t.state,          --NORMAL - обычная работа, CRITICAL - произошла критичная ошибка, выполнение операций приостановлено, сам процесс продолжает выполняться
       t.start_time, 
       t.stop_time, 
       t.last_execute,
       t.rowid
from   pdb_daemon_t t
order by start_time desc
/**/
