create or replace function get_table_alterxml(
  name1 in varchar2,
  name2 in varchar2
) return clob is
  diffdoc          clob;
  openw_handle     number;
  transform_handle number;
  alterxml         clob;
begin
  --
  -- Use the function just defined to get the difference document
  --
  diffdoc := compare_table_sxml(name1, name2);
  --
  -- Specify the object type in the OPENW call
  --
  openw_handle := dbms_metadata.openw('TABLE');
  --
  -- Use the ALTERXML transform to generate the ALTER_XML document
  --
  transform_handle := dbms_metadata.add_transform(openw_handle, 'ALTERXML');
  --
  -- Request parse items
  --
  dbms_metadata.set_parse_item(openw_handle, 'CLAUSE_TYPE');
  dbms_metadata.set_parse_item(openw_handle, 'NAME');
  dbms_metadata.set_parse_item(openw_handle, 'COLUMN_ATTRIBUTE');
  --
  -- Create a temporary LOB
  --
  dbms_lob.createtemporary(alterxml, true);
  --
  -- Call CONVERT to do the transform
  --
  dbms_metadata.convert(openw_handle, diffdoc, alterxml);
  --
  -- Close context and return the result
  --
  dbms_metadata.close(openw_handle);
  return alterxml;
end;
/
