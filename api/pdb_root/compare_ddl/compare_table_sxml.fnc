create or replace function compare_table_sxml(
  name1 in varchar2,
  name2 in varchar2
) return clob is
  doc1         clob;
  doc2         clob;
  diffdoc      clob;
  openc_handle number;
begin
  --
  -- Fetch the SXML for the two tables
  --
  doc1 := get_table_sxml(name1);
  doc2 := get_table_sxml(name2);
  --
  -- Specify the object type in the OPENC call
  --
  openc_handle := dbms_metadata_diff.openc('TABLE');
  --
  -- Add each document
  --
  dbms_metadata_diff.add_document(openc_handle, doc1);
  dbms_metadata_diff.add_document(openc_handle, doc2);
  --
  -- Fetch the SXML difference document
  --
  diffdoc := dbms_metadata_diff.fetch_clob(openc_handle);
  dbms_metadata_diff.close(openc_handle);
  return diffdoc;
end;
/
