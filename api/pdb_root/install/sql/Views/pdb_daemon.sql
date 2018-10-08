create or replace view pdb_daemon as
  select t.id,
         t.status,
         t.state,
         t.start_time,
         t.stop_time,
         t.last_execute         
  from   pdb_daemon_v t
  order by start_time desc
  fetch next 10 row only
/
