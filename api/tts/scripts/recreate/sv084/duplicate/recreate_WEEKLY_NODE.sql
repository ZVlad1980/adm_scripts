begin
  for pdb in (
        select t.pdb_name, cp.open_mode
        from   (
            select t.pdb_name,
                   t.open_mode,
                   t.pdb_created,
                   level lvl
            from   pdb_clones t
            start with t.pdb_name = 'WEEKLY_NODE'
            connect by prior t.pdb_name = t.pdb_parent
          ) t,
          v$pdbs cp
        where cp.name = t.pdb_name
        order by t.lvl desc, t.pdb_created desc
  ) loop
    begin
      if pdb.open_mode in ('READ WRITE', 'READ ONLY') then
        execute immediate 'alter pluggable database ' || pdb.pdb_name || ' close immediate';
        --dbms_output.put_line('alter pluggable database ' || pdb.pdb_name || ' close immediate');
      end if;
      execute immediate 'drop pluggable database ' || pdb.pdb_name || ' including datafiles';
    exception
      when others then
       dbms_output.put_line('Drop ' || pdb.pdb_name || ' failed: ' || sqlerrm);
    end;
    --dbms_output.put_line('drop pluggable database ' || pdb.pdb_name || ' including datafiles');
  end loop;
end;
/
host sleep 1200
/
host rm -fr /u01/app/oracle/oradata/weekly/WEEKLY_NODE/datafile
/
create pluggable database weekly_node admin user admin identified by admin file_name_convert=(
  '/u01/app/oracle/oradata/tstcdb/pdbseed/system01.dbf', '/u01/app/oracle/oradata/weekly/WEEKLY_NODE/datafile/system01.dbf',
  '/u01/app/oracle/oradata/tstcdb/pdbseed/sysaux01.dbf', '/u01/app/oracle/oradata/weekly/WEEKLY_NODE/datafile/sysaux01.dbf',
  '/u01/app/oracle/oradata/tstcdb/pdbseed/temp01.dbf', '/u01/app/oracle/oradata/tempfiles/weekly_node_temp01.dbf'
);
alter pluggable database weekly_node open;
alter session set container=weekly_node;
ALTER DATABASE TEMPFILE '/u01/app/oracle/oradata/tempfiles/weekly_node_temp01.dbf' RESIZE 5G;
ALTER DATABASE TEMPFILE '/u01/app/oracle/oradata/tempfiles/weekly_node_temp01.dbf' autoextend on maxsize 5G;
ALTER DATABASE dataFILE '/u01/app/oracle/oradata/weekly/WEEKLY_NODE/datafile/system01.dbf' RESIZE 9G;
ALTER DATABASE dataFILE '/u01/app/oracle/oradata/weekly/WEEKLY_NODE/datafile/sysaux01.dbf' RESIZE 1G;
connect system/passwd@weekly_node
CREATE OR REPLACE DIRECTORY data_dump_dir AS '/u01/app/oracle/buf/datapump';
exit
