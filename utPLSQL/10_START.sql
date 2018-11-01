create or replace package test_betwnstr as

  -- %suite(Between string function)

end;
/
begin ut.run(); end;
/
/*
Results:
Between string function
 
Finished in .451423 seconds
0 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)
*/
create or replace package test_betwnstr as

  -- %suite(Between string function)

  -- %test(Returns substring from start position to end position)
  procedure basic_usage;

end;
/
begin ut.run('test_betwnstr'); end;
/*
Results:
Between string function
  Returns substring from start position to end position [.013 sec] (FAILED - 1)
 
Failures:
 
  1) basic_usage
      ORA-04067: not executed, package body "NODE.TEST_BETWNSTR" does not exist
      ORA-06508: PL/SQL: could not find program unit being called: "NODE.TEST_BETWNSTR"
      ORA-06512: at line 6
Finished in .015607 seconds
1 tests, 0 failed, 1 errored, 0 disabled, 0 warning(s)
*/
create or replace package body test_betwnstr as

  procedure basic_usage is
  begin
    ut.expect( betwnstr( '1234567', 2, 5 ) ).to_equal('2345');
  end;

end;
/
begin ut.run('test_betwnstr'); end;
/*
Between string function
  Returns substring from start position to end position [.002 sec] (FAILED - 1)
 
Failures:
 
  1) basic_usage
      ORA-04063: package body "NODE.TEST_BETWNSTR" has errors
      ORA-06508: PL/SQL: could not find program unit being called: "NODE.TEST_BETWNSTR"
      ORA-06512: at line 6
Finished in .003761 seconds
1 tests, 0 failed, 1 errored, 0 disabled, 0 warning(s)
*/
--!!!!!!!!!!!!!!!!!!!!!
--Step 3: TDD
--!!!!!!!!!!!!
create or replace function betwnstr( a_string varchar2, a_start_pos integer, a_end_pos integer ) return varchar2
is
begin
  return substr( a_string, a_start_pos, a_end_pos - a_start_pos );
end;
/
begin ut.run('test_betwnstr'); end;
/
/*
Between string function
  Returns substring from start position to end position [.655 sec] (FAILED - 1)
 
Failures:
 
  1) basic_usage
      Actual: '234' (varchar2) was expected to equal: '2345' (varchar2) 
      at "NODE.TEST_BETWNSTR.BASIC_USAGE", line 5 ut.expect( betwnstr( '1234567', 2, 5 ) ).to_equal('2345');
      
       
Finished in .656794 seconds
1 tests, 1 failed, 0 errored, 0 disabled, 0 warning(s)
 
*/
create or replace function betwnstr( a_string varchar2, a_start_pos integer, a_end_pos integer ) return varchar2 
is
begin
  return substr( a_string, a_start_pos, a_end_pos - a_start_pos + 1 );
end;
/
begin ut.run('test_betwnstr'); end;
/
/*
Between string function
  Returns substring from start position to end position [.001 sec]
 
Finished in .002797 seconds
1 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)
 

*/
