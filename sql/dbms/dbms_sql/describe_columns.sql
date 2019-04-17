declare
  rc      sys_refcursor;
  c       number;
  d       number;
  col_cnt integer;
  f       boolean;
  rec_tab dbms_sql.desc_tab3;
  
  /**
    col_type            binary_integer   := 0,
    col_max_len         binary_integer   := 0,
    col_name            varchar2(32767)  := '',
    col_name_len        binary_integer   := 0,
    col_schema_name     varchar2(32)     := '',
    col_schema_name_len binary_integer   := 0,
    col_precision       binary_integer   := 0,
    col_scale           binary_integer   := 0,
    col_charsetid       binary_integer   := 0,
    col_charsetform     binary_integer   := 0,
    col_null_ok         boolean          := TRUE,
    col_type_name       varchar2(32)     := '',
    col_type_name_len   binary_integer   := 0);
  */
  procedure print_rec(rec in dbms_sql.desc_rec3) is
  begin
    dbms_output.put_line('col_type            =    ' || rec.col_type);
    dbms_output.put_line('col_maxlen          =    ' || rec.col_max_len);
    dbms_output.put_line('col_name            =    ' || rec.col_name);
    dbms_output.put_line('col_type_name       =    ' || rec.col_type_name    );
    dbms_output.put_line('col_type_name_len   =    ' || rec.col_type_name_len);
    dbms_output.put_line('col_null_ok         =    ' || case when rec.col_null_ok then 'true' else 'false' end);
  end print_rec;
  
begin
  --/* Define cursor, way 1
  open rc for
    select u.*
    from   all_users u;
  c := dbms_sql.to_cursor_number(rc);
  --*/
  /* Define cursor, way 2
  c := dbms_sql.open_cursor;
  dbms_sql.parse(c, 'select u.* from   all_users u', dbms_sql.native);
  d := dbms_sql.execute(c);
  --*/
  --Why is describe_columns3 exactly?
  dbms_sql.describe_columns3(
    c       => c,
    col_cnt => col_cnt,
    desc_t  => rec_tab
  );
  
  dbms_output.put_line('Column count: ' || col_cnt);
  /*
  * Following loop could simply be for j in 1..col_cnt loop.
  * Here we are simply illustrating some of the PL/SQL table
  * features.
  */
  for col_num in 1..col_cnt loop
    dbms_output.put_line(rpad('-', 30, '-'));
    dbms_output.put_line('Column num          =    ' || col_num);
    print_rec(rec_tab(col_num));
  end loop;
  dbms_output.put_line(rpad('-', 30, '-'));
  dbms_sql.close_cursor(c);
end;
/
