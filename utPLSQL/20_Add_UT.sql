create or replace package test_betwnstr as

  -- %suite(Between string function)

  -- %test(Returns substring from start position to end position)
  procedure basic_usage;

  -- %test(Returns substring when start position is zero)
  procedure zero_start_position;

end;
/

create or replace package body test_betwnstr as

  procedure basic_usage is
  begin
    ut.expect( betwnstr( '1234567', 2, 5 ) ).to_equal('2345');
  end;

  procedure zero_start_position is
  begin
    ut.expect( betwnstr( '1234567', 0, 5 ) ).to_equal('12345');
  end;

end;
/
begin ut.run('test_betwnstr'); end;
/*
Between string function
  Returns substring from start position to end position [.39 sec] (FAILED - 1)
  Returns substring when start position is zero [.001 sec]
 
Failures:
 
  1) basic_usage
      Actual: '234' (varchar2) was expected to equal: '2345' (varchar2) 
      at "NODE.TEST_BETWNSTR.BASIC_USAGE", line 5 ut.expect( betwnstr( '1234567', 2, 5 ) ).to_equal('2345');
      
       
Finished in .392687 seconds
2 tests, 1 failed, 0 errored, 0 disabled, 0 warning(s)
 
*/
/
create or replace function betwnstr( a_string varchar2, a_start_pos integer, a_end_pos integer ) return varchar2 
is
begin
  if a_start_pos = 0 then
    return substr( a_string, a_start_pos, a_end_pos - a_start_pos );
  else
    return substr( a_string, a_start_pos, a_end_pos - a_start_pos + 1);
  end if;
end;
/
begin ut.run('test_betwnstr'); end;
/*
Between string function
  Returns substring from start position to end position [.002 sec]
  Returns substring when start position is zero [.002 sec]
 
Finished in .005313 seconds
2 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)
 

*/
/
create or replace function betwnstr( a_string varchar2, a_start_pos integer, a_end_pos integer ) return varchar2
is
begin
  return substr( a_string, a_start_pos, a_end_pos - greatest( a_start_pos, 1 ) + 1 );
end;
/
begin ut.run('test_betwnstr'); end;
/*
Between string function
  Returns substring from start position to end position [.001 sec]
  Returns substring when start position is zero [.001 sec]
 
Finished in .004969 seconds
2 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)
 

*/
/
