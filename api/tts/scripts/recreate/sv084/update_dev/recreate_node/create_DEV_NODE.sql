alter pluggable database weekly_node open read only force;
create pluggable database DEV_NODE from WEEKLY_NODE file_name_convert=(
  '/u01/app/oracle/oradata/weekly/WEEKLY_NODE/datafile/', '/u01/app/oracle/oradata/dev/DEV_NODE/datafile/',
  '/u01/app/oracle/oradata/tempfiles/weekly_node_temp01.dbf', '/u01/app/oracle/oradata/tempfiles/dev_node_temp01.dbf'
);
alter pluggable database weekly_node close immediate;
alter pluggable database dev_node open;
alter session set container=dev_node;
ALTER DATABASE TEMPFILE '/u01/app/oracle/oradata/tempfiles/dev_node_temp01.dbf' RESIZE 5G;
ALTER DATABASE TEMPFILE '/u01/app/oracle/oradata/tempfiles/dev_node_temp01.dbf' autoextend on maxsize 5G;
exit
