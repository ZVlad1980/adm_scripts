PL/SQL Developer Test script 3.0
12
-- Created on 27.04.2018 by V.ZHURAVOV 
declare 
  -- Local variables here
  i integer;
begin
  -- Test statements here
  dbms_output.put_line(
    PDB_API.get_status_pdb@"c##pdbroot_tstcdb"(
      'ZPDB_NODE'
    )
  );
end;
0
0
