declare
  C_DB_LINK constant varchar2(32) := upper('pdb_root');
  
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
    from   user_db_links u
    where  u.db_link = C_DB_LINK;
    dbms_output.put_line('DBLink ' || C_DB_LINK || ' already exists');--ei('drop DATABASE LINK ' || C_DB_LINK);
  exception
    when no_data_found then
      ei('CREATE DATABASE LINK ' || C_DB_LINK || ' CONNECT TO pdb_root IDENTIFIED BY pdb_root USING ''(DESCRIPTION = (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))) (CONNECT_DATA = (SERVER=dedicated)(SERVICE_NAME=pdb_root)))''');
  end;

  

  ei('create or replace synonym pdb_actions_new for PDB_READY_ACTIONS_V@' || C_DB_LINK);
  ei('create or replace synonym pdb_actions for PDB_ACTIONS_V@' || C_DB_LINK);
  ei('create or replace synonym pdb_daemon for pdb_daemon_v@' || C_DB_LINK);
  ei('create or replace synonym pdb_daemon_log for pdb_daemon_log_t@' || C_DB_LINK);
  ei('create or replace synonym pdb_clones for pdb_clones_v@' || C_DB_LINK);
  ei('create or replace synonym pdb_api for pdb_api@' || C_DB_LINK);
end;
/
