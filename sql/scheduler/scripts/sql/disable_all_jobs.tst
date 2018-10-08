PL/SQL Developer Test script 3.0
85
-- Created on 04.06.2018 by V.ZHURAVOV 
declare 
  l_con_name varchar2(32) := 'CDB$ROOT';
  -- Local variables here
  cursor l_jobs_cur is
    select t.con_id,
           t.pdb_name,
           t.job_name
    from   (
            select j.con_id,
                   nvl(p.name, 'CDB$ROOT') pdb_name,
                   nvl(p.OPEN_MODE, 'READ WRITE') open_mode,
                   j.owner || '.' || j.job_name job_name
            from   cdb_scheduler_jobs j,
                   v$pdbs             p
            where  1=1
            and    p.con_id(+) = j.con_id
            and    j.enabled = 'TRUE'
           ) t
    where  t.open_mode = 'READ WRITE'
    order  by t.con_id,
              t.job_name;
  --
  type l_jobs_type is table of l_jobs_cur%rowtype;
  l_jobs l_jobs_type;
  --
  function get_current_container return varchar2 is
    l_result varchar2(128);
  begin
    select SYS_CONTEXT('USERENV', 'CON_NAME') NAME 
    into   l_result
    FROM DUAL;
    return l_result;
  end;
  --
  procedure ei(p_cmd varchar2) is
  begin
    dbms_output.put_line(p_cmd);
    execute immediate p_cmd;
  exception
    when others then
      dbms_output.put_line(sqlerrm);
      raise;
  end;
  --
  --
  procedure disable_job_(p_job l_jobs_cur%rowtype) is
    procedure disable_job_ is
    begin
      dbms_output.put('Disable job ' || p_job.job_name || ' ... ');
      dbms_scheduler.disable(
        name             => p_job.job_name,
        force            => true
      );
      dbms_output.put_line('Ok');
    exception
      when others then 
        dbms_output.put_line('Failed. ' || sqlerrm);
    end;
  begin
    if l_con_name <> p_job.pdb_name then
      l_con_name := p_job.pdb_name;
      ei('alter session set container=' || p_job.pdb_name);
    end if;
    disable_job_;
  end;
begin
  --dbms_session.reset_package; return;
  open l_jobs_cur;
  fetch l_jobs_cur
    bulk collect into l_jobs;
  close l_jobs_cur;
  
  l_con_name := get_current_container;
  for i in 1..l_jobs.count loop
    disable_job_(l_jobs(i));
  end loop;
  
  commit;
  
exception
  when others then
    ei('alter session set container=CDB$ROOT');
    raise;
end;
0
0
