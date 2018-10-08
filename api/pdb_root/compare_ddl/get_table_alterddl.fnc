create or replace function get_table_alterddl(
  name1 in varchar2,
  name2 in varchar2
) return clob is
  alterxml         clob;
  openw_handle     number;
  transform_handle number;
  alterddl         clob;
begin
  --
  -- Use the function just defined to get the ALTER_XML document
  --
  alterxml := get_table_alterxml(name1, name2);
  --
  -- Specify the object type in the OPENW call
  --
  openw_handle := dbms_metadata.openw('TABLE');
  --
  -- Use ALTERDDL transform to convert the ALTER_XML document to SQL DDL
  -- 
  transform_handle := dbms_metadata.add_transform(openw_handle, 'ALTERDDL');
  --
  -- Use the SQLTERMINATOR transform parameter to append a terminator
  -- to each SQL statement
  --
  dbms_metadata.set_transform_param(transform_handle,
                                    'SQLTERMINATOR',
                                    true);
  --
  -- Create a temporary lob
  --
  dbms_lob.createtemporary(alterddl, true);
  --
  -- Call CONVERT to do the transform
  --
  dbms_metadata.convert(openw_handle, alterxml, alterddl);
  --
  -- Close context and return the result
  --
  dbms_metadata.close(openw_handle);
  return alterddl;
end;
/
