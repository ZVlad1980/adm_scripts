PL/SQL Developer Test script 3.0
12
-- Created on 09.07.2018 by V.ZHURAVOV 
declare 
  -- Local variables here
  i integer;
begin
  -- Test statements here
  pdb_api.add_database(
    p_pdb_name   => 'WEEKLY_NODE',
    p_clone_name => 'WEEKLY_CLONE',
    p_acfs_path  => '/u01/app/oracle/oradata/weekly'
  );
end;
0
0
