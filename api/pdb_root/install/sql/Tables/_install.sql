prompt !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
prompt Create PDB_ROOT tables
prompt !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
prompt

@@pdb_clones_t.sql
@@pdb_root_pdb_actions_t.sql
@@pdb_root_pdb_daemon_log_t.sql
@@pdb_root_pdb_daemon_t.sql

@_conn "c##pdbroot/c##pdbroot as sysdba";
@@c##_clone_pdb_ext_t.sql
@@c##_files_pdb_ext_t.sql
prompt
prompt
prompt
prompt !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
prompt Complete create PDB_ROOT tables
prompt !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
