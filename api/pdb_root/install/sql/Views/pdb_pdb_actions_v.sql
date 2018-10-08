create or replace view pdb_actions_v as
  select a.id, 
         a.action        action, 
         a.pdb_name      pdb_name, 
         a.pdb_parent    pdb_parent,
         a.pdb_path,
         a.planned_at,
         a.status        status, 
         a.critical, 
         a.result, 
         a.start_process,
         a.end_process,
         a.created_at,
         a.updated_at
  from   pdb_actions_t a
/
