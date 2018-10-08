timing start install
prompt Install API PDB_ROOT
prompt
prompt
set echo off
set show off
set timing on
set verify off
set serveroutput on
spool ./install.log

set term off
@_conn "/ as sysdba"
column 1 new_value 1 noprint
select '' "1" from dual where rownum = 0;
define l_db_create_file_dest = '&1'
set term on

set feedback off
prompt Install Users
@Users/_install.sql;
@_conn "pdb_root/pdb_root@localhost:1521/pdb_root";
@Tables/_install.sql
@_conn "pdb_root/pdb_root@localhost:1521/pdb_root";
@Views/_install.sql
@_conn "pdb_root/pdb_root@localhost:1521/pdb_root";
@Packages/_install.sql
@_conn "pdb_root/pdb_root@localhost:1521/pdb_root";
@Triggers/_install.sql
@_conn "pdb_root/pdb_root@localhost:1521/pdb_root";
@PackageBodies/_install.sql

prompt
prompt
prompt Install complete
timing stop
spool off

exit

