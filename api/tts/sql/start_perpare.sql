declare
  l_result  varchar2(20);
  l_err_msg varchar2(32767);
begin
  vbz.tts_api.prepare_transport_db(
    x_status    => l_result , 
    x_error_msg => l_err_msg
  );
  
  dbms_output.put_line(l_result || chr(10) || l_err_msg);
  
end;
