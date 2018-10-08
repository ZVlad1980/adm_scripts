declare
  C_MODE constant varchar2(20) := 'enable'; --enable --disable
  --
  cursor l_ref_constr_cur is
    select c.table_name, c.constraint_name
    from   user_constraints c
    where  c.status <> upper(C_MODE || 'd')
    and    c.constraint_type = 'R';
  --
  cursor l_triggers_cur is
    select t.table_name
    from   user_tables t
    where  exists (
             select 1 
             from   user_triggers tr 
             where  tr.table_owner = user 
             and    tr.base_object_type = 'TABLE' 
             and    tr.table_name = t.table_name 
             and    tr.status <> upper(C_MODE || 'd')
           );
  procedure ei(p_cmd varchar2) is
  begin
    dbms_output.put(rpad(p_cmd || ' ', 80, '.') || ' ');
    execute immediate p_cmd;
    dbms_output.put_line('Ok');
  exception
    when others then
      dbms_output.put_line('Error: ' || sqlerrm);
  end;
begin
  --
  dbms_output.put_line(initcap(lower(C_MODE)) || ' all ref constraints of ' || user);
  for rc in l_ref_constr_cur loop
    ei('alter table ' || rc.table_name || ' ' || C_MODE || ' constraint ' || rc.constraint_name);
  end loop;
  --
  dbms_output.put_line(rpad('.', 100, '.'));
  --
  for t in l_triggers_cur loop
    ei('alter table ' || t.table_name || ' ' || C_MODE || ' all triggers');
  end loop;
  --
  dbms_output.put_line(rpad('.', 100, '.'));
  --
  /*if user='CDM' and C_MODE = 'disable' then
    for t in (select s.sequence_name from user_sequences s) loop
      ei('drop sequence ' || t.sequence_name );
    end loop;
  end if;
  --*/
end;
/
