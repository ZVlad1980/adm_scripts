PL/SQL Developer Test script 3.0
15
-- Created on 11.05.2018 by V.ZHURAVOV 
declare 
  -- Local variables here
  C_CLONE_CONF   constant varchar2(120) := 'clone_pdb.conf';
  l_file         utl_file.file_type;
begin
  -- Test statements here
  l_file := utl_file.fopen(
    location     => 'PDB_CLONES_DIR',
    filename     => C_CLONE_CONF,
    open_mode    => 'w'
  );
  utl_file.put_line(l_file, 'source_path=/u01/app/oracle/oradata/TESTCDB/6BEBA6538ADE176AE055E371072A900A/datafile');
  utl_file.fclose(l_file);
end;
0
0
