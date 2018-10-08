PL/SQL Developer Test script 3.0
19
-- Created on 14.05.2018 by V.ZHURAVOV 
declare 
  -- Local variables here
  i integer;
begin
  --dbms_session.reset_package; return;
  -- Test statements here
  pdb_pub.clone(p_creator => 'VBZ', p_pdb_name => 'TSTDB');--, p_pdb_parent => 'TESTDB');
  /*
  pdb_pub.clone(p_creator => 'VBZ', p_pdb_name => 'VBZ_TSTDB_CL_01', p_pdb_parent => 'VBZ_TSTDB');
  pdb_pub.clone(p_creator => 'VBZ', p_pdb_name => 'VBZ_TSTDB_CL_02', p_pdb_parent => 'VBZ_TSTDB');
  pdb_pub.clone(p_creator => 'VBZ', p_pdb_name => 'VBZ_TSTDB_CL_021', p_pdb_parent => 'VBZ_TSTDB_CL_02');
  pdb_pub.clone(p_creator => 'VBZ', p_pdb_name => 'VBZ_TSTDB2_CL_01', p_pdb_parent => 'VBZ_TSTDB2');
  pdb_pub.clone(p_creator => 'VBZ', p_pdb_name => 'VBZ_TSTDB2_CL_02', p_pdb_parent => 'VBZ_TSTDB2');
  pdb_pub.clone(p_creator => 'VBZ', p_pdb_name => 'VBZ_TSTDB2_CL_021', p_pdb_parent => 'VBZ_TSTDB2_CL_02');
  --pdb_pub.drop_(p_pdb_name => 'VBZ_TSTDB_CL_02');*/
  --pdb_pub.clone(p_creator => 'VBZ', p_pdb_name => 'VBZ_TSTDB_CL_021', p_pdb_parent => 'VBZ_TSTDB_CL_02');
  --pdb_pub.clone(p_creator => 'VBZ', p_pdb_name => 'VBZ_TSTDB2_CL_021', p_pdb_parent => 'VBZ_TSTDB2_CL_02');
end;
0
0
