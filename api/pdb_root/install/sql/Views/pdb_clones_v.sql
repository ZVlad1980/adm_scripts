create or replace view pdb_clones_v as
  select cp.id,
         cp.pdb_name,
         cp.pdb_parent,
         cp.open_mode,
         cp.refreshable,
         cp.freeze,
         case 
           when exists(
             select 1
             from   pdb_clones_t cp2 
             where  cp2.pdb_name = cp.pdb_parent
             and    cp2.pdb_parent is not null
           ) then
             'YES'
           else
             'NO'
         end clone_of_clone,
         case
           when exists(
             select 1
             from   pdb_clones_t cp2 
             where  cp2.pdb_parent = cp.pdb_name
             and    cp2.open_mode <> 'NOT EXISTS'
           ) then
             'YES'
           else
             'NO'
         end childs_exists,
         case
           when exists(
             select 1
             from   pdb_clones_t cp2 
             where  cp2.freeze = 'YES'
             and    cp2.pdb_name <> cp.pdb_name
             start with cp2.pdb_name = cp.pdb_name
             connect by prior cp2.pdb_name = cp2.pdb_parent
           ) then
             'YES'
           else
             'NO'
         end childs_freeze,
         cp.before_action,
         cp.after_action,
         cp.pdb_created,
         cp.creator,
         cp.default_parent,
         cp.last_open_mode,
         cp.created_at,
         cp.updated_at,
         cp.thin_clone,
         cp.acfs_path
  from   pdb_clones_t cp
/
