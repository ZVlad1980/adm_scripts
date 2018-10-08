prompt
prompt !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
prompt Create PDB_ROOT triggers
prompt !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
prompt

@_conn "pdb_root/pdb_root@localhost:1521/pdb_root";
prompt Create pdb_actions_au_trg.trg
@@pdb_actions_au_trg.trg
show errors

prompt Create pdb_clones_biu_trg.trg
@@pdb_clones_biu_trg.trg
show errors
prompt
prompt !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
prompt Create PDB_ROOT triggers complete
prompt !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
