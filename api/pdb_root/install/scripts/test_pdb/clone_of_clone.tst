PL/SQL Developer Test script 3.0
12
-- Created on 11.05.2018 by V.ZHURAVOV 
declare 
  -- Local variables here
  i integer;
begin
  --dbms_session.reset_package; return;
  -- Test statements here
  pdb_daemon_api.clone_of_clone_pdb(
    p_pdb_source => 'PDB_CLONE11',
    p_pdb_target => 'PDB_CLONE12'
  );
end;
0
0
