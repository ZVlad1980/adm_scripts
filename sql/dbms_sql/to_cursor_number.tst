PL/SQL Developer Test script 3.0
100
declare
  rc      sys_refcursor;
  c       number;
  d       number;
  col_cnt integer;
  f       boolean;
  rec_tab dbms_sql.desc_tab3;
  col_num number;
  l_val   varchar2(32767);
  namevar varchar2(32767);
  numvar  number;
  datevar date;

  procedure print_rec(rec in dbms_sql.desc_rec3) is
  begin
    /*
    col_type            binary_integer := 0,
    col_max_len         binary_integer := 0,
    col_name            varchar2(32767) := '',
    col_name_len        binary_integer := 0,
    col_schema_name     varchar2(32)   := '',
    col_schema_name_len binary_integer := 0,
    col_precision       binary_integer := 0,
    col_scale           binary_integer := 0,
    col_charsetid       binary_integer := 0,
    col_charsetform     binary_integer := 0,
    col_null_ok         boolean        := TRUE,
    col_type_name       varchar2(32)   := '',
    col_type_name_len   binary_integer := 0);
    */
    dbms_output.put_line('col_type            =    ' || rec.col_type);
    dbms_output.put_line('col_maxlen          =    ' || rec.col_max_len);
    dbms_output.put_line('col_name            =    ' || rec.col_name);
    dbms_output.put_line('col_type_name       =    ' || rec.col_type_name);
    dbms_output.put_line('col_type_name_len   =    ' ||
                         rec.col_type_name_len);
    dbms_output.put('col_null_ok  = ');
    if (rec.col_null_ok) then
      dbms_output.put_line('true');
    else
      dbms_output.put_line('false');
    end if;
  end;
begin
  open rc for
    select d.*
    from   hr.employees d
    where  rownum = 1;

  c := dbms_sql.to_cursor_number(rc);
  dbms_output.put_line(c);
  --c := dbms_sql.open_cursor;

  --dbms_sql.parse(c, 'SELECT t.*, http_nodes(http_text(''test'')) node FROM hr.employees t', dbms_sql.native);

  --d := dbms_sql.execute(c);

  dbms_sql.describe_columns3(c, col_cnt, rec_tab);

  /*
  * Following loop could simply be for j in 1..col_cnt loop.
  * Here we are simply illustrating some of the PL/SQL table
  * features.
  */
  col_num := rec_tab.first;
  while (col_num is not null) loop
    dbms_sql.define_column(c, col_num, namevar, 1024);/*
    if rec_tab(col_num).col_type = 2 then
      dbms_sql.define_column(c, col_num, numvar);
    elsif rec_tab(col_num).col_type = 12 then
      dbms_sql.define_column(c, col_num, datevar);
    else
      dbms_sql.define_column(c, col_num, namevar, 25);
    end if; /*
      dbms_output.put_line('Column num: ' || col_num);
        print_rec(rec_tab(col_num));*/
        col_num := rec_tab.next(col_num);
  end loop;

  while dbms_sql.fetch_rows(c) > 0 loop
    for i in 1 .. col_cnt loop
      
      dbms_sql.column_value(c, i, l_val);
      /*l_val := 'undefined';
      if (rec_tab(i).col_type = 1) then
        dbms_sql.column_value(c, i, namevar);
        l_val := namevar;
      elsif (rec_tab(i).col_type = 2) then
        dbms_sql.column_value(c, i, numvar);
        l_val := to_char(numvar);
      elsif (rec_tab(i).col_type = 12) then
        dbms_sql.column_value(c, i, datevar);
        l_val := to_char(datevar, 'yyyymmdd');
      end if;*/
      dbms_output.put_line(rec_tab(i).col_name || ': ' || l_val);
    end loop;
  end loop;

  dbms_sql.close_cursor(c);
end;
0
0
