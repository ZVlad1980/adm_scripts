connect / as sysdba
@@set_env.sql
alter system reset background_dump_dest scope=spfile;
alter system reset core_dump_dest scope=spfile;
alter system reset user_dump_dest scope=spfile;
alter user system identified by "passwd";
alter user sys identified by "oSposC.c";
alter system set job_queue_processes=0 scope=both;
alter system set "_use_single_log_writer"=TRUE scope=spfile;
alter system set "_kdt_buffering"=FALSE scope=spfile;
shutdown immediate;
startup mount;
alter database noarchivelog;
alter database open;
ARCHIVE LOG LIST;
alter trigger ALEX.CAPTURE_TRACE_FILES disable;
update gazfond.app_settings t set t.application_title='Test Environment' where id=0;
update gazfond_pn.app_settings t set t.application_title='Test Environment' where id=0;
alter user gazfond identified by gazfond;
alter user gazfond_pn identified by gazfond_pn;
alter user fnd identified by fnd;
alter user cdm identified by cdm;
grant create any context to gazfond;
grant execute on dbms_rls to gazfond;
grant execute on dbms_lock to gazfond;
grant execute on dbms_lock to gazfond_pn;
grant execute on dbms_lock to fnd;
grant execute on dbms_lock to cdm;
grant select on v_$session to gazfond, gazfond_pn, cdm;
grant create any context to gazfond_pn;
grant execute on dbms_rls to gazfond_pn;
create or replace trigger gazfond_chg_sess after logon on gazfond.schema
begin
  execute immediate 'alter session set "_optimizer_adaptive_plans"=false';
end;
/
create or replace trigger gazfond_pn_chg_sess after logon on gazfond_pn.schema
begin
  execute immediate 'alter session set "_optimizer_adaptive_plans"=false';
end;
/
declare 
  cursor c_jobs is
    select j.owner ||'.' || j.job_name job_name
    from   all_scheduler_jobs j
    where  j.enabled = 'TRUE';
    --
begin

  for j in c_jobs loop
    begin
      dbms_output.put('Disable job ' || j.job_name || ' ... ');
      dbms_scheduler.disable(
        name             => j.job_name,
        force            => true
      );
      dbms_output.put_line('Ok');
    exception
      when others then 
        dbms_output.put_line('Failed. ' || sqlerrm);
    end;
  end loop;

end;
/
exit;
