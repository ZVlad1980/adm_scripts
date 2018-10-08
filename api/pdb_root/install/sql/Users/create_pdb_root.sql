declare
  C_PDB constant varchar2(32) := upper('pdb_root');
  C_DEST constant varchar2(200) := '/u01/app/oracle/oradata/tstcdb/';--'1'; --/u01/app/oracle/oradata/tstcdb/
  C_TS constant varchar2(32) := upper('USERDATA');
  C_USER constant varchar2(32) := upper('PDB_ROOT');
  
  l_dummy     int;
  
  procedure ei(p_cmd varchar2) is
  begin
    execute immediate p_cmd;
  exception
    when others then
      dbms_output.put_line(p_cmd || ' failed. ' || sqlerrm);
      raise;
  end;
  
  procedure grant_to_(p_resource varchar2) is
  begin
    ei('grant ' || p_resource || ' to ' || C_USER);
  end;
  
begin

  begin
    select 1
    into   l_dummy
    from   user_tablespaces t
    where  t.tablespace_name = C_TS;
    
    dbms_output.put_line('Tablespace ' || C_TS || ' already exists.');
    
  exception
    when no_data_found then
      if C_DEST is not null then
        ei('alter session set db_create_file_dest=''' || C_DEST || '''');
      end if;
      ei('CREATE SMALLFILE TABLESPACE ' || C_TS || ' datafile size 500M AUTOEXTEND ON NEXT 100M MAXSIZE 2G blocksize 16K');
      ei('alter user ' || C_USER || ' identified by ' || lower(C_USER) || ' default tablespace ' || C_TS || ' quota 100M on ' || C_TS);
  end;
  
  grant_to_('resource, connect, create table, create procedure, create view, create sequence, create synonym');
  grant_to_('DEBUG ANY PROCEDURE');
  grant_to_('DEBUG CONNECT SESSION');
  grant_to_('execute on dbms_lock');
  grant_to_('select on dba_data_files');
  
end;
/
