PL/SQL Developer Test script 3.0
35
begin
  pdb_pub.clone(
    p_creator     => 'PDB_ROOT',
    p_pdb_name    => 'WEEKLY',
    p_pdb_parent  => 'WEEKLY_CLONE'
  );
  pdb_pub.clone(
    p_creator     => 'PDB_ROOT',
    p_pdb_name    => 'WEEKLY_VBZ',
    p_pdb_parent  => 'WEEKLY_CLONE'
  );
  --pdb_pub.clone(p_creator => 'VBZ', p_pdb_name => 'TSTDB_TTS', p_pdb_parent => 'TSTDB');
  --pdb_pub.unfreeze_(p_pdb_name => 'TSTDB');
--  pdb_pub.clone(p_creator => 'VBZ', p_pdb_name => 'TSTDB_TTS2', p_pdb_parent => 'TSTDB');
  --pdb_pub.open_(p_pdb_name => 'TSTDB');
  --pdb_pub.freeze_(p_pdb_name => 'TSTDB');
  --pdb_pub.clone(p_creator => 'VBZ', p_pdb_name => 'TSTDB_TTS2_1', p_pdb_parent => 'TSTDB_TTS2');
  /*--Размораживаем PDB источник
  pdb_pub.unfreeze_(p_pdb_name => 'VBZ_TSTDB');
  --создаем клон
  pdb_pub.clone(p_creator => 'VBZ', p_pdb_name => 'VBZ_TSTDB_01', p_pdb_parent => 'VBZ_TSTDB');
  --открываем и замораживаем PDB-источник
  pdb_pub.open_(p_pdb_name => 'VBZ_TSTDB');
  pdb_pub.freeze_(p_pdb_name => 'VBZ_TSTDB');
  */
  --pdb_pub.open_(p_pdb_name => '');
  --pdb_pub.unfreeze_(p_pdb_name => 'VBZ_TSTDB');
  --pdb_pub.close_(p_pdb_name => 'VBZ_TSTDB');
  --pdb_pub.request_drop(p_pdb_name => 'VBZ_TSTDB_01');
 /* pdb_api.action(p_action      => pdb_api.GC_ACT_CLONE,
                 p_pdb_name    => 'VBZ_TSTDB2',
                 p_creator     => 'VBZ',
                 p_planned_at  => sysdate + 1
                 ); --*/
end;
0
0
