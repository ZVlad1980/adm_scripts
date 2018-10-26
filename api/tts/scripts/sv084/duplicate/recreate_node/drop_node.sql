set serveroutput on
declare
  l_node_name varchar2(50) := '&1';
begin
  dbms_output.enable(100000);
  dbms_output.put_line('Node: ' || l_node_name);
  for pdb in (
        select t.pdb_name, cp.open_mode
        from   (
            select t.pdb_name,
                   t.open_mode,
                   t.pdb_created,
                   level lvl
            from   pdb_clones t
            start with t.pdb_name = l_node_name --'WEEKLY_NODE'
            connect by prior t.pdb_name = t.pdb_parent
          ) t,
          v$pdbs cp
        where cp.name = t.pdb_name
        order by t.lvl desc, t.pdb_created desc
  ) loop
    
    begin
      if pdb.open_mode in ('READ WRITE', 'READ ONLY') then
        execute immediate 'alter pluggable database ' || pdb.pdb_name || ' close immediate';
        --dbms_output.put_line('alter pluggable database ' || pdb.pdb_name || ' close immediate');
      end if;
      execute immediate 'drop pluggable database ' || pdb.pdb_name || ' including datafiles';
      --dbms_output.put_line('drop pluggable database ' || pdb.pdb_name || ' including datafiles');
    exception
      when others then
       dbms_output.put_line('Drop ' || pdb.pdb_name || ' failed: ' || sqlerrm);
    end;
    
  end loop;
end;
/
exit 0
