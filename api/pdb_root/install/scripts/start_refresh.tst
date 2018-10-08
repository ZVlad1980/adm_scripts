PL/SQL Developer Test script 3.0
11
-- Created on 15.05.2018 by V.ZHURAVOV 
declare 
  -- Local variables here
  i integer;
begin
  -- Test statements here
  pdb_api.refresh_pdbs(
    p_action => pdb_api.GC_RFSH_DROP, --_RESTORE_MODE, --pdb_api.GC_RFSH_START
    p_synch_mode => true
  );
end;
0
0
