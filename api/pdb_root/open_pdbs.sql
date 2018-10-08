/*
    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 PDB_ROOT                       READ WRITE NO
         4 PDB_NODE                       MOUNTED
         5 TSTDB                          READ WRITE NO
         6 BASE_CLONE                     READ ONLY  NO
         7 PDB_RELEASE1                   READ WRITE NO
         8 SUT_PDB001                     READ WRITE NO
         9 ANIKIN_TESTDB                  READ WRITE NO
        10 BSV_PDB000                     READ WRITE NO
*/
begin
/*  pdb_pub.open_ro_('BASE_CLONE');
  pdb_pub.open_('TSTDB');
  pdb_pub.open_('PDB_RELEASE1');
  pdb_pub.open_('SUT_PDB001');
  pdb_pub.open_('ANIKIN_TESTDB');
  pdb_pub.open_('BSV_PDB000');
  */
  pdb_pub.freeze_('BASE_CLONE');
  pdb_pub.freeze_('TSTDB');
  pdb_pub.freeze_('PDB_RELEASE1');
  pdb_pub.freeze_('SUT_PDB001');
  pdb_pub.freeze_('ANIKIN_TESTDB');
  pdb_pub.freeze_('BSV_PDB000');
end;
