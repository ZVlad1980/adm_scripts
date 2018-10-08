prompt
prompt !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
prompt Create PDB_ROOT views
prompt !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
prompt

@_conn "c##pdbroot/c##pdbroot as sysdba"
prompt Create c##_cdb_all_files_v.sql
@@c##_cdb_all_files_v.sql
show errors

@_conn "pdb_root/pdb_root@localhost:1521/pdb_root";
prompt Create pdb_clones_v.sql
@@pdb_clones_v.sql
show errors

prompt Create pdb_clones.sql
@@pdb_clones.sql
show errors

prompt Create pdb_pdb_daemon_log_v.sql
@@pdb_pdb_daemon_log_v.sql
show errors

prompt Create pdb_daemon_log_v.sql
@@pdb_daemon_log_v.sql
show errors

prompt Create pdb_pdb_actions_v.sql
@@pdb_pdb_actions_v.sql
show errors

prompt Create pdb_pdb_actions.sql
@@pdb_pdb_actions.sql
show errors

prompt Create pdb_pdb_daemon_v.sql
@@pdb_pdb_daemon_v.sql
show errors

prompt Create pdb_pdb_daemon.sql
@@pdb_pdb_daemon.sql
show errors

prompt Create pdb_pdb_ready_actions_v.sql
@@pdb_pdb_ready_actions_v.sql
show errors

prompt
prompt !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
prompt Create PDB_ROOT views complete
prompt !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
