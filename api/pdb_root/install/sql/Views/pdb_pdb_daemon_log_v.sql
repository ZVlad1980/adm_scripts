create or replace view pdb_daemon_log_v as
  select d.message,
         d.error,
         d.created_at
  from   pdb_daemon_log_t d
  order by d.created_at desc
/
