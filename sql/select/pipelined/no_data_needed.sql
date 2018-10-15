--CREATE TYPE t IS TABLE OF NUMBER/
CREATE OR REPLACE FUNCTION pipe_rows RETURN t PIPELINED AUTHID DEFINER IS
  n NUMBER := 0;
BEGIN
  dbms_output.put_line('Start');
  LOOP
    n := n + 1;
    PIPE ROW (n);
    dbms_output.put_line(n);
  END LOOP;
  dbms_output.put_line('Complete');
exception
  when no_data_needed then
    dbms_output.put_line('Handler no_data_needed');
  when others then
    dbms_output.put_line(sqlerrm);
    raise;
END pipe_rows;
/
SELECT COLUMN_VALUE
FROM TABLE(pipe_rows())
WHERE ROWNUM < 5
