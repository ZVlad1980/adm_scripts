JOB_NAME = 'CONTRIBUTIONS_ADMISSION_JOB';
/
declare
  cursor j_cur is
    SELECT sj.owner, sj.job_name
    FROM DBA_SCHEDULER_JOBS sj
    WHERE state = 'RUNNING';
begin
  for j in j_cur loop
    dbms_output.PUT('Stop job ' || j.owner || '.' || j.job_name || '...');
    begin
      dbms_scheduler.stop_job(job_name => j.owner || '.' || j.job_name, force => true);
      dbms_output.put_line('Ok');
    exception
      when others then
        dbms_output.put_line('Error: ' || sqlerrm);
    end;
  end loop;
end;
