PL/SQL Developer Test script 3.0
13
-- Created on 09.06.2018 by V.ZHURAVOV 
declare 
  -- Local variables here
  i integer;
begin
  --dbms_session.reset_package; return;
  -- Test statements here
  pdb_api.add_database(
    p_pdb_name          => 'DEV_DB',
    p_clone_name        => 'DEV_CLONE',
    p_acfs_path         => '/u01/app/oracle/oradata/dev'
  );
end;
0
0
