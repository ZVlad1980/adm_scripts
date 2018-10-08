PL/SQL Developer Test script 3.0
25
-- Created on 12.05.2018 by V.ZHURAVOV 
declare 
  -- Local variables here
  function get_file_name_convert(
    p_pdb_source          varchar2,
    p_pdb_target          varchar2,
    p_db_create_file_dest varchar2
  ) return varchar2 is
    l_result varchar2(32767);
    --
    cursor l_pdb_files(p_type int) is
      select pdb.file_type,
             pdb.file_name,
             pdb.file_num,
             pdb.tablespace_name
      from   cdb_all_files_v pdb
      where  pdb.pdb_name = p_pdb_source;
    --
  begin
    
  end;
begin
  -- Test statements here
  
end;
0
0
