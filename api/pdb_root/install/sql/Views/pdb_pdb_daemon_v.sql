create or replace view pdb_daemon_v as
  select d.id, 
         d.status, 
         d.state, 
         d.start_time, 
         d.stop_time, 
         d.last_execute, 
         d.critical_time, 
         d.critical_action_id
  from   pdb_daemon_t d
/
