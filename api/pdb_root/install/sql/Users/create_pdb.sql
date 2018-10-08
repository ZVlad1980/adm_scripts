declare
  C_PDB constant varchar2(32) := upper('pdb_root');
  C_DEST constant varchar2(200) := '&1';  --/u01/app/oracle/oradata/tstcdb/
  C_TS constant varchar2(32) := upper('USERDATA');
  C_USER constant varchar2(32) := upper('PDB_ROOT');
  
  l_open_mode v$pdbs.OPEN_MODE%type;
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
 dbms_output.put_line('Before create pdb_root'); --return; 
  begin
    select p.OPEN_MODE
    into   l_open_mode
    from   v$pdbs p
    where  p.NAME = C_PDB;
    
    dbms_output.put_line('PDB_ROOT already exists, mode: ' || l_open_mode);
    
  exception
    when no_data_found then
      if C_DEST is not null then
        ei('alter session set db_create_file_dest=''' || C_DEST || '''');
      end if;
      ei('create pluggable database ' || C_PDB || ' admin user ' || lower(C_PDB) || ' identified by ' || lower(C_PDB) || '');
      l_open_mode := 'MOUNT';
  end;
  
  if l_open_mode <> 'READ WRITE' then
    ei('alter pluggable database ' || C_PDB || ' open');
    dbms_output.put_line('alter PDB_ROOT, new mode: ' || l_open_mode);
  end if;
  
end;
/

