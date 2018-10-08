host rm -fr /u01/app/oracle/oradata/weekly/WEEKLY_NODE/datafile
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
