select t.id,
               t.pdb_name
        from   pdb_clones_v t
        where  t.freeze = 'NO'
        and    t.childs_freeze = 'NO'
        and    not exists (
                 select 1
                 from   pdb_clones_v cc
                 where  cc.pdb_created > t.pdb_created
                 and    cc.open_mode <> 'NOT EXISTS'
                 and    (cc.freeze = 'YES' or cc.childs_freeze = 'YES')
               )
        order by t.pdb_created desc
