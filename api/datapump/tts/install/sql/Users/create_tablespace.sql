alter session set db_create_file_dest='/u01/app/oracle/oradata/pdbs/&instance';
create pluggable database &instance admin user admin identified by passwd;
alter session set container=&instance;
alter pluggable database open;
CREATE BIGFILE TABLESPACE USERDATA datafile size 500M AUTOEXTEND ON NEXT 100M MAXSIZE 2G blocksize 16K;

