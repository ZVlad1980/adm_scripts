declare
  C_NODE_NAME  pdb_clones.pdb_name%type; := 'WEEKLY_NODE';
  
  l_base_clone pdb_clones.pdb_name%type;
  
  cursor l_clones_cur is
    select t.pdb_name,
           t.pdb_parent,
           t.open_mode,
           t.last_open_mode,
           t.creator,
           (select c.freeze    from pdb_clones c where c.pdb_name = t.pdb_parent) parent_freeze,
           level lvl
    from   pdb_clones t
    where  t.open_mode = 'NOT EXISTS'
    start  with t.pdb_name = 'WEEKLY_NODE' --C_NODE_NAME
    connect by prior t.pdb_name = t.pdb_parent
    order by  level, t.pdb_created;
  
  type l_clones_typ is table of l_clones_cur%rowtype;
  l_clones l_clones_typ;
begin
  open l_clones_cur;
  fetch l_clones_cur
    bulk collect into l_clones;
  close l_clones_cur;
  
  for i in 1..l_clones.last loop
    if l_clones.parent_freeze = 'YES' then
      pdb_pub.unfreeze_(p_pdb_name => p.pdb_parent);
    end if;
    pdb_pub.clone(p_creator => p.creator, p_pdb_name => p.pdb_name, p_pdb_parent => p.pdb_parent);
    if p.lvl = 2 then
      l_base_clone := p.pdb_name;
    end if;
  end loop;
  pdb_pub.close_(p_pdb_name => C_NODE_NAME);
  pdb_pub.freeze_(p_pdb_name => C_NODE_NAME);
  pdb_pub.open_ro_(l_base_clone
end;
/
