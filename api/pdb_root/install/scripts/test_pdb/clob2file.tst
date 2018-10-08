PL/SQL Developer Test script 3.0
76
-- Created on 14.05.2018 by V.ZHURAVOV 
declare
  c_describe_xml constant varchar2(120) := 'clone_pdb.xml';
  c_clone_dir    constant varchar2(32) := 'PDB_CLONES_DIR';
  l_describe_xml clob := '<?xml version="1.0" encoding="UTF-8"?>
<PDB>
  <xmlversion>1</xmlversion>
  <pdbname>PDB_CLONE11</pdbname>
  <cid>11</cid>
  <byteorder>1</byteorder>
  <vsn>203424000</vsn>
  <vsns>
    <vsnnum>12.2.0.1.0</vsnnum>
    <cdbcompt>12.2.0.0.0</cdbcompt>
    <pdbcompt>12.2.0.0.0</pdbcompt>
    <vsnlibnum>0.0.0.0.24</vsnlibnum>
    <vsnsql>24</vsnsql>
    <vsnbsv>8.0.0.0.0</vsnbsv>
  </vsns>
  <dbid>927054406</dbid>
  <ncdb2pdb>0</ncdb2pdb>
</PDB>
';
  -- Local variables here
  procedure clob2file_ is
    l_file     utl_file.file_type;
    l_str      varchar2(32767);
    l_position integer := 1;
    l_offset   integer := 1;
    l_new_line varchar2(1) := chr(10);
    l_max_length integer;
    
    function get_str_(p_str out varchar2) return boolean is
    begin
      if l_offset >= l_max_length then
        return false;
      end if;
      
      l_position := instr(l_describe_xml, l_new_line, l_offset);
      
      if l_position <= 0 then
        l_position := l_max_length;
      end if;
      
      p_str := dbms_lob.substr(
        lob_loc => l_describe_xml,
        amount  => (l_position - l_offset),
        offset  => l_offset
      ); 
      
      l_offset := l_position + 1;
      
      return true;
    end;
    
  begin
    --return;
    l_file := utl_file.fopen(
      location  => c_clone_dir,
      filename  => c_describe_xml,
      open_mode => 'w'
    );
    
    l_max_length := dbms_lob.getlength(l_describe_xml);
  
    while get_str_(l_str) loop
      utl_file.put_line(l_file, l_str);
    end loop;
  
    utl_file.fclose(l_file);
    
  end;
begin
  -- Test statements here
  clob2file_;
end;
0
1
l_str
