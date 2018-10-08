create or replace function get_table_sxml(name in varchar2) return clob is
  open_handle      number;
  transform_handle number;
  doc              clob;
begin
  open_handle := dbms_metadata.open('TABLE');
  dbms_metadata.set_filter(open_handle, 'NAME', name);
  --
  -- Use the 'SXML' transform to convert XML to SXML
  --
  transform_handle := dbms_metadata.add_transform(open_handle, 'SXML');
  --
  -- Use this transform parameter to suppress physical properties
  --
  dbms_metadata.set_transform_param(transform_handle,
                                    'PHYSICAL_PROPERTIES',
                                    false);
  doc := dbms_metadata.fetch_clob(open_handle);
  dbms_metadata.close(open_handle);
  return doc;
end;
/
