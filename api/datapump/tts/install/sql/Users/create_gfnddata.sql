alter session set db_create_file_dest='/u01/app/oracle/oradata/pdbs/evday';
CREATE BIGFILE TABLESPACE GFNDDATA datafile size 30G AUTOEXTEND ON NEXT 500M MAXSIZE 70G blocksize 16K
/
/*
FOR DESTINATION
alter session set db_create_file_dest='/u01/app/oracle/oradata/pdbs/weekly';
CREATE smallfile TABLESPACE GFNDDATA datafile size 1M AUTOEXTEND ON NEXT 5M MAXSIZE 7M blocksize 16K
import metadata cdm
drop tablespace gfnddata including contents and datafiles;
*/
alter tablespace gfnddata online;
