create or replace view daemon_log_v as
  select d.message,
         d.error,
         d.created_at
  from   pdb_daemon_log_v d
  order by d.created_at desc
  fetch next 100 rows only
/
