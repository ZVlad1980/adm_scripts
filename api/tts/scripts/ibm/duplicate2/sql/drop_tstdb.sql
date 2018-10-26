connect / as sysdba
@@set_env.sql
prompt Connected as sysdba to
show con_name
declare
  l_open_mode v$pdbs.open_mode%type;
begin
  select cp.open_mode into l_open_mode from v$pdbs cp where cp.name = 'TSTDB';
  if l_open_mode <> 'MOUNTED' then
    execute immediate 'alter pluggable database tstdb close immediate';
  end if;
  execute immediate 'drop pluggable database tstdb';
exception
  when no_data_found then
    dbms_output.put_line('PDB TSTDB not found');
end;
/
show pdbs
shut immediate
exit
