declare
  C_USER constant varchar2(32) := upper('c##pdbroot');
  
  l_dummy int;
  
  procedure ei(p_cmd varchar2) is
  begin
    execute immediate p_cmd;
  exception
    when others then
      dbms_output.put_line(p_cmd || ' failed. ' || sqlerrm);
      raise;
  end;
  
begin
  
  begin
    select 1
    into   l_dummy
    from   all_users u
    where  u.username = C_USER;
    dbms_output.put_line('User ' || C_USER || ' already exists');
  exception
    when no_data_found then
      ei('create user ' || C_USER || ' identified by ' || lower(C_USER) || ' container=all');
  end;
  
  ei('grant sysdba to ' || C_USER || ' container=all');
  --ei('grant create directory to ' || C_USER || ' container=all');
  ei('grant create database link TO ' || C_USER || ' container=all');
  ei('grant resource, connect, DEBUG ANY PROCEDURE,  DEBUG CONNECT SESSION TO ' || C_USER || ' container=all');
  ei('grant create procedure to ' || C_USER || ' container=all');
  ei('grant create synonym to ' || C_USER || ' container=all');
  ei('grant execute on dbms_lock to ' || C_USER || '');
end;
/
