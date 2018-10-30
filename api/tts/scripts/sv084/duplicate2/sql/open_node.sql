conn / as sysdba
@@set_env.sql

declare
  l_node_name varchar2(50) := '&1';
  l_open_mode varchar2(50);
  
  function is_open_mode return boolean is
    l_result boolean;
  begin
    select cp.OPEN_MODE
    into   l_open_mode
    from   v$pdbs cp
    where  cp.name = l_node_name;
    
    dbms_output.put_line(l_node_name || ': ' || l_open_mode);
    return l_open_mode = 'READ WRITE';
  end;
begin
  if not is_open_mode then
    execute immediate 'alter pluggable database ' || l_node_name || ' open read write force';
    --dbms_output.put_line('alter pluggable database ' || l_node_name || ' open read write force');
    if not is_open_mode then
      dbms_output.put_line(l_node_name || ': not opened');
      raise program_error;
    end if;
  end if;
exception
  when others then
    dbms_output.put_line(l_node_name || ': ' || sqlerrm);
    raise;
end;
/
exit success