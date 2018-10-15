declare
  l_users varchar2(250) := 'oe';
  l_obj_list odcivarchar2list :=
    odcivarchar2list(
      'v_$session',
      'v_$sql_plan_statistics_all',
      'v_$sql_plan',
      'v_$sql'
    );
  procedure grant_(
    p_object varchar2
  ) is
    l_cmd varchar2(1024);
  begin
    l_cmd := 'grant select on ' || p_object || ' to ' || l_users;
    execute immediate l_cmd;
  exception
    when others then
      dbms_output.put_line(l_cmd || chr(10) || sqlerrm);
      raise;
  end;
begin
  for i in 1..l_obj_list.count loop
    grant_(l_obj_list(i));
  end loop;
  dbms_output.put_line('Complete');
end;
    
