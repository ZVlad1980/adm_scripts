PL/SQL Developer Test script 3.0
36
-- Created on 27.04.2018 by V.ZHURAVOV 
declare 
  -- Local variables here
  C_LOCK_NAME   constant varchar2(50) := 'TEST_LOCK';
  l_lock_handle varchar2(50);
  l_result      integer;
begin
  -- Test statements here
  dbms_lock.allocate_unique(
    lockname        => C_LOCK_NAME,
    lockhandle      => l_lock_handle
  );
  dbms_output.put_line('Lock handle: ' || l_lock_handle);

  l_result := dbms_lock.request(
      lockhandle        => l_lock_handle,
      timeout           => 0
    );
  
  dbms_output.put_line('request lock result: ' || l_result);
  
  if l_result <> 0 then
    raise program_error;
  end if;
  
  dbms_lock.sleep(10);
  
  l_result := dbms_lock.release(lockhandle => l_lock_handle);
  
  dbms_output.put_line('request unlock result: ' || l_result);
  
  if l_result <> 0 then
    raise program_error;
  end if;
  
end;
0
0
