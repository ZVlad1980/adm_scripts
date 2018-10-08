declare
  C_DIRECTORY constant varchar2(32) := upper('PDB_CLONES_DIR');
  C_PATH      constant varchar2(200) := '/home/oracle/tstcdb/pdb_daemon/clone';
  C_USER      constant varchar2(32) := user;
  
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
  ei('CREATE OR REPLACE DIRECTORY ' || C_DIRECTORY || ' AS ''' || C_PATH || '''');/*
  begin
    select 1
    into   l_dummy
    from   dba_directories d
    where  d.DIRECTORY_NAME = C_DIRECTORY;
    dbms_output.put_line('Directory ' || C_DIRECTORY || ' already exists');--ei('drop DATABASE LINK ' || C_DB_LINK);
  exception
    when no_data_found then
      ei('CREATE OR REPLACE DIRECTORY ' || C_DIRECTORY || ' AS ''' || C_PATH || '''');
  end;
--*/
  ei('GRANT ALL ON DIRECTORY ' || C_DIRECTORY || '  TO ' || C_USER);
  
end;
/
