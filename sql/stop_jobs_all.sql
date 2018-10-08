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
/
declare
  cursor l_jobs_cur is
    select s.owner, s.job_name
    from   all_scheduler_jobs s
    where  s.enabled = 'TRUE'
    --and    s.owner <> 'SYS'
    ;
begin
  for job in l_jobs_cur loop
    dbms_output.put(job.owner || '.' || job.job_name || ' ');
    begin
      dbms_scheduler.disable(name => job.owner || '.' || job.job_name, force => true);
      dbms_output.put_line('Ok');
    exception
    when others then
      dbms_output.put_line('Error: ' || sqlerrm);
    end;
  end loop;
end;
/
declare
  cursor l_jobs_cur is
    select s.owner, s.job_name, s.enabled
  from   all_scheduler_jobs s
  where  s.owner = 'SYS' --
  and    enabled = 'FALSE';
begin
  for job in l_jobs_cur loop
    dbms_output.put(job.owner || '.' || job.job_name || ' ');
    begin
      dbms_scheduler.enable(name => job.owner || '.' || job.job_name);
      dbms_output.put_line('Ok');
    exception
    when others then
      dbms_output.put_line('Error: ' || sqlerrm);
    end;
  end loop;
end;
/

  
