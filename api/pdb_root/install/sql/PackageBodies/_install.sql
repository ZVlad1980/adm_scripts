prompt
prompt !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
prompt Create PDB_ROOT package bodies
prompt !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
prompt

@_conn "c##pdbroot/c##pdbroot as sysdba";
prompt Create cdb_pdb_daemon.pkb
@@cdb_pdb_daemon.pkb
show errors

@_conn "pdb_root/pdb_root@localhost:1521/pdb_root";
prompt Create pdb_api.pkb
@@pdb_api.pkb
show errors
prompt Create pdb_pub.pkb
@@pdb_pub.pkb
show errors
prompt
prompt !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
prompt Create PDB_ROOT package bodies complete
prompt !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
