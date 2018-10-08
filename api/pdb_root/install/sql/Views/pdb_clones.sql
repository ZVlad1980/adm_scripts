create or replace view pdb_clones as
  select t.id,
         t.pdb_name,
         rpad('=', level - 1, '=') || '>' lvl,
         t.pdb_parent,
         t.open_mode,
         t.refreshable,
         t.freeze,
         t.pdb_created,
         t.creator,
         t.default_parent,
         t.last_open_mode
  from   pdb_clones_v t
  start with t.pdb_parent is null
  connect by prior t.pdb_name = t.pdb_parent
  order SIBLINGS by t.pdb_created
/
