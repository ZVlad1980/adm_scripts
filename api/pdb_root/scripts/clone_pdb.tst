PL/SQL Developer Test script 3.0
15
-- Created on 20.04.2018 by V.ZHURAVOV 
declare 
  -- Local variables here
  l_status  varchar2(1);
  l_sts_msg varchar2(32767);
begin
  -- Test statements here
  pdb_api.clone_pdb(
    p_status     => l_status ,
    p_status_msg => l_sts_msg,
    p_pdb_source => 'PDB_TSTDB',
    p_pdb_target => 'PDB000'
  );
  dbms_output.put_line('Status: ' || l_status || chr(10) || 'Message: ' || l_sts_msg);
end;
0
0
