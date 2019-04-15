PL/SQL Developer Test script 3.0
33
declare
  c       NUMBER;
  d       NUMBER;
  n_tab   DBMS_SQL.NUMBER_TABLE;
  indx    NUMBER := 1;
  v       number;
BEGIN
  c := DBMS_SQL.OPEN_CURSOR;
  dBMS_SQL.PARSE(c, 'select code from test_tbl order by 1', DBMS_SQL.NATIVE);

  DBMS_SQL.DEFINE_ARRAY(c, 1, n_tab, 100, indx);

  d := DBMS_SQL.EXECUTE(c);
  loop
    d := DBMS_SQL.FETCH_ROWS(c);
    dbms_output.put_line('d: ' || d);
    DBMS_SQL.COLUMN_VALUE(c, 1, n_tab);
    --DBMS_SQL.variable_value(c, 'code', n_tab);
    dbms_output.put_line('n_tab.count: ' || n_tab.count);
    for i in 1..n_tab.count loop
      dbms_output.put_line('n_tab(' || i || '): ' || n_tab(i));
    end loop;
    EXIT WHEN d != 100;
  END LOOP;

  DBMS_SQL.CLOSE_CURSOR(c);

  EXCEPTION WHEN OTHERS THEN
    IF DBMS_SQL.IS_OPEN(c) THEN
      DBMS_SQL.CLOSE_CURSOR(c);
    END IF;
    RAISE;
END;
0
0
