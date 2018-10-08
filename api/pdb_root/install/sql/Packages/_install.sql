prompt
prompt !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
prompt Create PDB_ROOT packages
prompt !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
prompt

@_conn "c##pdbroot/c##pdbroot as sysdba"
prompt Create cdb_pdb_daemon.pks
@@cdb_pdb_daemon.pks
show errors

@_conn "pdb_root/pdb_root@localhost:1521/pdb_root";
prompt Create pdb_api.pks
@@pdb_api.pks
show errors
prompt Create pdb_pub.pks
@@pdb_pub.pks
show errors
prompt
prompt !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
prompt Create PDB_ROOT packages complete
prompt !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
