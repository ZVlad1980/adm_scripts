create or replace view pdb_actions as
  select t.id, 
         t.action, 
         t.pdb_name, 
         t.pdb_parent,
         t.planned_at,
         t.status,
         t.start_process,
         t.end_process,
         t.created_at,
         t.updated_at
  from   pdb_actions_v t
  order by t.planned_at desc, t.created_at desc
/
