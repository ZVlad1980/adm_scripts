PL/SQL Developer Test script 3.0
57
-- Created on 23.05.2018 by V.ZHURAVOV 
declare 
  type l_schema_type is record (
    name varchar2(30),
    dir varchar2(30),
    exclude_tables_file varchar2(100)
  );
  
  p_schema l_schema_type;
  -- Local variables here
  procedure load_tables_ is
    l_file UTL_FILE.FILE_TYPE;
    l_line varchar2(500);
  begin
    begin
      l_file := utl_file.fopen(
        location     => p_schema.dir,
        filename     => p_schema.exclude_tables_file,
        open_mode    => 'r'
      );
    exception
      when others then
        dbms_output.put_line('Exclude tables file: ' || p_schema.dir || '/' || p_schema.exclude_tables_file || ' open failed.');
        return;
    end;
    loop
      begin
        utl_file.get_line(
          file   => l_file,
          buffer => l_line
        );
      exception
        when no_data_found then
          exit;
      end;
      l_line := replace(trim(l_line), chr(13), '');
      exit when l_line is null;
      dbms_output.put_line(l_line);
    end loop;
    --
    utl_file.fclose(l_file);
    --
  exception
    when others then
      dbms_output.put_line('load_file_(' || p_schema.name || ')');
      raise;
  end load_tables_;
begin
  -- Test statements here
  --return;
  p_schema.name      := 'CDM';
  p_schema.dir       := upper('gfdump_' || p_schema.name || '_dir');
--  p_schema.dump_file := lower(l_schemas(i).name) || to_char(p_date_dump, 'yymmdd') || '%U.dpdmp';
  --p_schema.log_file  := 'import_' || lower(l_schemas(i).name);
  p_schema.exclude_tables_file := 'exclude_' || lower(p_schema.name) || '.conf';
  load_tables_;
end;
0
0
