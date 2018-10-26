def pdb = '&1';
conn sys/"oSposC.c"@"${pdb}" as sysdba
@@set_env.sql
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
grant execute on dbms_lock to inf;
grant execute on dbms_lock to inf_pn;
grant execute on dbms_lock to gazfond;
grant execute on dbms_lock to gazfond_pn;
grant execute on dbms_lock to fnd;
grant execute on dbms_lock to cdm;
grant select on v_$session to gazfond, gazfond_pn, cdm;
set serveroutput on
exec dbms_stats.gather_system_stats();
exec sys.dbms_stats.gather_system_stats('START');
alter session disable parallel query;
select /*+ FULL(a) */ count(*) from gazfond_pn.people a;
exec sys.dbms_stats.gather_system_stats('STOP');
alter table gazfond.documents add REG_DEPT_NUM_FOR_SORT VARCHAR2(14) GENERATED ALWAYS AS (COALESCE(LPAD(REG_DEPT_NUM,14,'0'),'00000000000000')) VIRTUAL  NOT NULL ENABLE;
alter table gazfond.documents add REG_ACT_NUM_FOR_SORT VARCHAR2(14) GENERATED ALWAYS AS (COALESCE(LPAD(REG_ACT_NUM,14,'0'),'00000000000000')) VIRTUAL  NOT NULL ENABLE;
alter table gazfond.documents add REG_DOC_NUM_FOR_SORT VARCHAR2(14) GENERATED ALWAYS AS (COALESCE(LPAD(REG_DOC_NUM,14,'0'),'00000000000000')) VIRTUAL  NOT NULL ENABLE;
alter table gazfond_pn.documents add REG_DEPT_NUM_FOR_SORT VARCHAR2(14) GENERATED ALWAYS AS (COALESCE(LPAD(REG_DEPT_NUM,14,'0'),'00000000000000')) VIRTUAL  NOT NULL ENABLE;
alter table gazfond_pn.documents add REG_ACT_NUM_FOR_SORT VARCHAR2(14) GENERATED ALWAYS AS (COALESCE(LPAD(REG_ACT_NUM,14,'0'),'00000000000000')) VIRTUAL  NOT NULL ENABLE;
alter table gazfond_pn.documents add REG_DOC_NUM_FOR_SORT VARCHAR2(14) GENERATED ALWAYS AS (COALESCE(LPAD(REG_DOC_NUM,14,'0'),'00000000000000')) VIRTUAL  NOT NULL ENABLE;
alter table gazfond.doc_copy add REG_DEPT_NUM_FOR_SORT VARCHAR2(14) GENERATED ALWAYS AS (COALESCE(LPAD(REG_DEPT_NUM,14,'0'),'00000000000000')) VIRTUAL  NOT NULL ENABLE;
alter table gazfond.doc_copy add REG_ACT_NUM_FOR_SORT VARCHAR2(14) GENERATED ALWAYS AS (COALESCE(LPAD(REG_ACT_NUM,14,'0'),'00000000000000')) VIRTUAL  NOT NULL ENABLE;
alter table gazfond.doc_copy add REG_DOC_NUM_FOR_SORT VARCHAR2(14) GENERATED ALWAYS AS (COALESCE(LPAD(REG_DOC_NUM,14,'0'),'00000000000000')) VIRTUAL  NOT NULL ENABLE;
alter table gazfond_pn.doc_copy add REG_DEPT_NUM_FOR_SORT VARCHAR2(14) GENERATED ALWAYS AS (COALESCE(LPAD(REG_DEPT_NUM,14,'0'),'00000000000000')) VIRTUAL  NOT NULL ENABLE;
alter table gazfond_pn.doc_copy add REG_ACT_NUM_FOR_SORT VARCHAR2(14) GENERATED ALWAYS AS (COALESCE(LPAD(REG_ACT_NUM,14,'0'),'00000000000000')) VIRTUAL  NOT NULL ENABLE;
alter table gazfond_pn.doc_copy add REG_DOC_NUM_FOR_SORT VARCHAR2(14) GENERATED ALWAYS AS (COALESCE(LPAD(REG_DOC_NUM,14,'0'),'00000000000000')) VIRTUAL  NOT NULL ENABLE;
CREATE INDEX BNA.IDX_KPPPSW_DEPT ON BNA.KPP_PASS (BNA.KPP_GET_DEPT(ID)) PARALLEL 5;
CREATE INDEX FND.IDX_IZM_REF_MEM ON FND.IZMENENIYA (FND.IZM_REFERS_MEMBER(KOD_IZM))  PARALLEL 5;
CREATE INDEX FND.IDX_NUM_VAL ON FND.IZM_KEY_VAL (FND.SAFE_TO_NUMBER(VAL))  PARALLEL 5;
CREATE INDEX FND.IDX_REG_DOC_FN_ISH ON FND.REG_DOC_INSZ (FND.REG_GET_DOC_ISH(KOD_INSZ))  PARALLEL 5;
CREATE INDEX FND.IDX_SVID_DATNOMDOG ON FND.DOC_SVID (FND.SVID_GET_DATA_NOM_DOG(DATA_DOG,NOM_DOG)) PARALLEL 5;
CREATE INDEX GAZFOND.DOCUMENT_REGDEPTACTNUM_IDX ON GAZFOND.DOCUMENTS (REG_DEPT_NUM_FOR_SORT, REG_ACT_NUM_FOR_SORT, REG_DOC_NUM_FOR_SORT)  PARALLEL 5;
CREATE INDEX GAZFOND.DOC_COPY_REGDEPTACTNUM_IDX ON GAZFOND.DOC_COPY (REG_DEPT_NUM_FOR_SORT, REG_ACT_NUM_FOR_SORT, REG_DOC_NUM_FOR_SORT)  PARALLEL 5;
CREATE INDEX GAZFOND_PN.DOCUMENT_REGDEPTACTNUM_IDX ON GAZFOND_PN.DOCUMENTS (REG_DEPT_NUM_FOR_SORT, REG_ACT_NUM_FOR_SORT, REG_DOC_NUM_FOR_SORT)  PARALLEL 5;
CREATE INDEX GAZFOND_PN.DOC_COPY_REGDEPTACTNUM_IDX ON GAZFOND_PN.DOC_COPY (REG_DEPT_NUM_FOR_SORT, REG_ACT_NUM_FOR_SORT, REG_DOC_NUM_FOR_SORT)  PARALLEL 5
/
declare
  l_cmd varchar2(32767);
  l_output_amount number;
  cursor l_invalids_cur is
    select tt.owner,
           tt.object_type,
           tt.object_name,
           tt.status
    from   (select ao.owner,
                   ao.object_type,
                   ao.object_name,
                   ao.status
            from   all_objects ao
            where  1 = 1
            and    ao.status <> 'VALID'
            and    ao.owner in (select u.username from all_users u where  u.common = 'NO')
            minus
            select t.owner,
                   t.object_type,
                   t.object_name,
                   t.status
            from   vbz.tts_invalids_t t) tt
    where  tt.object_type not in ('JAVA SOURCE')
    order  by case tt.object_type
                when 'PACKAGE' then 1
                when 'VIEW' then 2
                when 'SYNONYM' then 3
                else
                 99
              end;
  procedure ei(p_cmd varchar2) is
  begin
    execute immediate p_cmd;
  exception
    when others then
      raise;
  end;
begin
  --
  l_output_amount := 0;
  for i in 1 .. 3 loop
    for o in l_invalids_cur loop
      if o.object_type in ('PACKAGE', 'TYPE') then
        l_cmd := 'alter ' || o.object_type || ' ' || o.owner || '.' ||
                 o.object_name || ' compile specification';
      elsif o.object_type in ('PACKAGE BODY', 'TYPE BODY') then
        l_cmd := 'alter ' ||
                 substr(o.object_type, 1, instr(o.object_type, ' ') - 1) || ' ' ||
                 o.owner || '.' || o.object_name || ' compile body';
      elsif o.object_type = 'JAVA CLASS' then
        l_cmd := 'alter java class "' || o.owner || '"."' || o.object_name ||
                 '" resolve';
      else
        l_cmd := 'alter ' || o.object_type || ' ' || o.owner || '.' ||
                 o.object_name || ' compile';
      end if;
      begin
        ei(l_cmd);
      exception
        when others then
          if i = 3 and l_output_amount < 500 then
            dbms_output.put_line(l_cmd || ' fail.' || chr(10) || sqlerrm);
            l_output_amount := l_output_amount + 1;
          end if;
      end;
    end loop;
  end loop;
  --
exception
  when others then
    dbms_output.put_line('Recompile failed: ' || sqlerrm);
    raise;
end;
/
column owner format a6;
column object_type format a15;
column object_name format a20;
column status format a10;
select tt.owner,
       tt.object_type,
       tt.object_name,
       tt.status
from   (
        select ao.owner,
               ao.object_type,
               ao.object_name,
               ao.status
        from   all_objects ao
        where  1 = 1
        and    ao.status <> 'VALID'
        and    ao.owner in (select u.username
                            from   all_users u
                            where  u.common = 'NO')
        minus
        select t.owner, t.object_type, t.object_name, t.status
        from   vbz.tts_invalids_t t
       ) tt
order by 
  case tt.object_type
    when 'PACKAGE' then 1
    when 'VIEW' then 2
    when 'SYNONYM' then 3
    else 99
  end
/
conn pdb_root/pdb_root@pdb_root
@@set_env.sql
begin
  -- Test statements here
  pdb_api.recreate_pdbs(p_pdb_node => '&pdb');
end;
/
exit;
