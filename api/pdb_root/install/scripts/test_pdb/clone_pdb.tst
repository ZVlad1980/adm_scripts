PL/SQL Developer Test script 3.0
16
-- Created on 29.04.2018 by V.ZHURAVOV 
declare 
  -- Local variables here
  i integer;
begin
  -- Test statements here
  /*--pdb_pub.clone(p_creator => 'PDB_ROOT', p_pdb_name => 'dev_clone', p_pdb_parent => 'DEV_NODE' );
  pdb_pub.close_(p_pdb_name => 'DEV_NODE');
  pdb_pub.freeze_(p_pdb_name => 'DEV_NODE');
  pdb_pub.clone(p_creator => 'PDB_ROOT', p_pdb_name => 'DEV', p_pdb_parent => 'DEV_CLONE' );
  */
  --pdb_pub.clone(p_creator => 'PDB_ROOT', p_pdb_name => 'PDB_RELEASE1', p_pdb_parent => 'DEV_CLONE' );
  --pdb_pub.clone(p_creator => 'PDB_ROOT', p_pdb_name => 'DDECLONE1', p_pdb_parent => 'DEV_CLONE' );
  --pdb_pub.clone(p_creator => 'PDB_ROOT', p_pdb_name => 'ANIKIN_TSTDB', p_pdb_parent => 'DEV_CLONE' );
  pdb_pub.clone(p_creator => 'VBZ', p_pdb_name => 'DEV_VBZ', p_pdb_parent => 'DEV_CLONE' );
end;
0
0
