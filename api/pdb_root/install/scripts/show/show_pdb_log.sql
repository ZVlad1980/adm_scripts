select t.message,      --сообщение API
       t.error,        --детализация ошибки
       t.created_at
from   pdb_daemon_log t
