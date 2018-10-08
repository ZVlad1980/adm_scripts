@_conn "/ as sysdba"
prompt run create_pdb.sql
@@create_pdb.sql &l_db_create_file_dest;
prompt

alter session set container=pdb_root;
set serveroutput on
prompt run create_pdb_root.sql
@@create_pdb_root.sql &l_db_create_file_dest;
prompt

@_conn "/ as sysdba"
prompt run create_c##pdbroot.sql
@@create_c##pdbroot.sql;
prompt

@_conn "c##pdbroot/c##pdbroot as sysdba";
prompt run c##_create_dblink.sql
@@create_c##_dblink.sql;
@@create_c##_directory.sql;
prompt
