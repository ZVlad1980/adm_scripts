PL/SQL Developer Test script 3.0
20
-- Created on 30.06.2018 by V.ZHURAVOV 
declare 
  -- Local variables here
  i integer;
begin
  -- Test statements here
  pdb_pub.unfreeze_(p_pdb_name =>  'DEV_CLONE');
  pdb_pub.unfreeze_(p_pdb_name =>  'DEV');
  pdb_pub.unfreeze_(p_pdb_name =>  'WEEKLY_NODE');
  pdb_pub.open_ro_(p_pdb_name => 'DEV_CLONE');
  pdb_pub.open_(p_pdb_name => 'DEV');
  pdb_pub.open_(p_pdb_name => 'PDB_RELEASE1');
  pdb_pub.open_(p_pdb_name => 'DDECLONE1');
  pdb_pub.open_(p_pdb_name => 'ANIKIN_TSTDB');
  pdb_pub.open_(p_pdb_name => 'DEV_VBZ');
  pdb_pub.open_(p_pdb_name => 'WEEKLY_NODE');
  pdb_pub.freeze_(p_pdb_name =>  'DEV_CLONE');
  pdb_pub.freeze_(p_pdb_name =>  'DEV');
  pdb_pub.freeze_(p_pdb_name =>  'WEEKLY_NODE');
end;
0
0
