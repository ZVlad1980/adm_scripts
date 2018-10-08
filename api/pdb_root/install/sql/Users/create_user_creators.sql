declare
  l_users sys.odcivarchar2list := sys.odcivarchar2list(
    'VBZ',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '' --*/
  );
  
  procedure ie(p_cmd varchar2) is
  begin
    dbms_output.put_line(p_cmd);
  exception
    when others then
      dbms_output.put_line(p_cmd || chr(10) || sqlerrm);
      raise;
  end;
  
  procedure create_user(p_user_name) is
  begin
    ei('create user ' || p_user_name || ' identified by ' || lower(p_user_name));
    ei('grant connect to ' || p_user_name);
    ei('grant execute on pdb_root.pdb_pub to ' || p_user_name);
    ei('grant select on pdb_root.pdb_clones_v to ' || p_user_name);
    ei('grant select on pdb_root.pdb_daemon_log_v to ' || p_user_name);
    ei('grant select on pdb_root.pdb_actions_v to ' || p_user_name);
    ei('grant select on pdb_root.pdb_daemon_v to ' || p_user_name);
  exception
    when others then
      null;
  end;
  
begin
  for i in 1..l_users.count loop
    create_user(l_users(i));
  end loop;
end;
