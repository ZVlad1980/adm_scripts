PL/SQL Developer Test script 3.0
36
declare
  c     number;
  d     number;
  n_tab dbms_sql.number_table;
  indx  number := 1;
  v     number;
begin
  c := dbms_sql.open_cursor;
  dbms_sql.parse(c,
                 'select code from test_tbl order by 1',
                 dbms_sql.native);

  dbms_sql.define_array(c, 1, n_tab, 100, indx);

  d := dbms_sql.execute(c);
  loop
    d := dbms_sql.fetch_rows(c);
    dbms_output.put_line('d: ' || d);
    dbms_sql.column_value(c, 1, n_tab);
    --DBMS_SQL.variable_value(c, 'code', n_tab);
    dbms_output.put_line('n_tab.count: ' || n_tab.count);
    for i in 1 .. n_tab.count loop
      dbms_output.put_line('n_tab(' || i || '): ' || n_tab(i));
    end loop;
    exit when d != 100;
  end loop;

  dbms_sql.close_cursor(c);

exception
  when others then
    if dbms_sql.is_open(c) then
      dbms_sql.close_cursor(c);
    end if;
    raise;
end;
0
0
