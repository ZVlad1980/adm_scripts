create table pdb_daemon_log_t(
  message     varchar2(500),
  error       varchar2(4000),
  created_at  timestamp default systimestamp
)
/
