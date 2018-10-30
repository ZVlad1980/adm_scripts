def dump_dir = '&1';
connect system/passwd@tstdb
@@set_env.sql
create table vbz.tts_invalids_t as 
  select ao.owner,
         ao.object_type,
         ao.object_name,
         ao.status,
         ao.last_ddl_time
  from   all_objects ao
  where  1=1
  and    ao.status <> 'VALID'
  and    ao.owner in (
           select u.username from all_users u where u.common = 'NO'
         );
drop index bna.IDX_KPPPSW_DEPT;
drop index fnd.IDX_IZM_REF_MEM;
drop index fnd.IDX_NUM_VAL;
drop index fnd.IDX_REG_DOC_FN_ISH;
drop index fnd.IDX_SVID_DATNOMDOG;
drop table VBZ.DV_SR_LSPV_CORRECTION_T;
drop function fnd.OPS_ADD_DOGOVOR_DATA_MDM;
drop function fnd.OPS_ADD_ZAYAV_DATA_MDM;
drop type FND.ER_REFCURSOR;
drop type FND.TRANS_T;
drop type FND.ASSIGNMENT_TAB;
drop type GAZFOND.T_INP_ROW1;
drop index gazfond.DOCUMENT_REGDEPTACTNUM_IDX;
alter table gazfond.documents drop column REG_DEPT_NUM_FOR_SORT;
alter table gazfond.documents drop column REG_ACT_NUM_FOR_SORT;
alter table gazfond.documents drop column REG_DOC_NUM_FOR_SORT;
drop index gazfond_pn.DOCUMENT_REGDEPTACTNUM_IDX;
alter table gazfond_pn.documents drop column REG_DEPT_NUM_FOR_SORT;
alter table gazfond_pn.documents drop column REG_ACT_NUM_FOR_SORT;
alter table gazfond_pn.documents drop column REG_DOC_NUM_FOR_SORT;
drop index gazfond.DOC_COPY_REGDEPTACTNUM_IDX;
alter table gazfond.doc_copy drop column REG_DEPT_NUM_FOR_SORT;
alter table gazfond.doc_copy drop column REG_ACT_NUM_FOR_SORT;
alter table gazfond.doc_copy drop column REG_DOC_NUM_FOR_SORT;
drop index gazfond_pn.DOC_COPY_REGDEPTACTNUM_IDX;
alter table gazfond_pn.doc_copy drop column REG_DEPT_NUM_FOR_SORT;
alter table gazfond_pn.doc_copy drop column REG_ACT_NUM_FOR_SORT;
alter table gazfond_pn.doc_copy drop column REG_DOC_NUM_FOR_SORT;

alter table BNA.DATA_155 modify DATE_ZANES DATE default trunc(sysdate);
alter table BNA.DATA_152 modify DATE_ZANES DATE default trunc(sysdate);
alter table BNA.DATA_153 modify DATE_ZANES DATE default trunc(sysdate);
alter table BNA.DATA_154 modify DATA_STATUS DATE default to_date('31.03.2009', 'dd.mm.yyyy');
alter table BNA.DATA_266 modify DATE_RSH DATE default to_date('30.08.2013', 'dd.mm.yyyy');
alter table BNA.DATA_272 modify DATE_SOST DATE default to_date('15.05.2014', 'dd.mm.yyyy');
alter table BNA.DATA_153 modify DATE_ZANES DATE default trunc(sysdate);
alter table BNA.DATA_153 modify DATE_ZANES DATE default trunc(sysdate);
alter table DWH.DWH_TBL_FIZLITS_BUFTR modify SYS_DATE DATE default trunc(sysdate);
alter table DWH.DWH_TBL_OUTSUM_BUFTR modify SYS_DATE DATE default trunc(sysdate);
alter table DWH.DWH_TBL_AVGPEN_BUFTR modify SYS_DATE DATE default trunc(sysdate);
alter table MDM.OPS_REESTR_NPO_BUF modify SYS_DATE DATE default trunc(sysdate);
alter table UMG.TBL_DWH_NV_SH2_SET modify SYS_DATE DATE default trunc(sysdate);
alter table UMG.TBL_DWH_NV_SH2_SFL modify SYS_DATE DATE default trunc(sysdate);
alter table UMG.TBL_DWH_NV_SH2_TTIPS modify SYS_DATE DATE default trunc(sysdate);
alter table UMG.WEB_SP_REPORTS modify REP_DATE DATE default trunc(sysdate);
alter table UMG.TBL_DWH_NV_SH2_DVIPS modify SYS_DATE DATE default trunc(sysdate);
alter table UMG.APP_ZAYAV modify DATE_SYS DATE default trunc(sysdate);
alter table UMG.SH0_VZN_REPORT_NEW modify DATA_ZANES DATE default trunc(sysdate);
alter table UMG.SH1_VZN_ONIPS_BUF_AUTO modify DATA_DONE DATE default trunc(sysdate);
alter table UMG.SH1_VZN_REPORT_NEW modify DATA_ZANES DATE default trunc(sysdate);
alter table UMG.SH2_VZN_ONIPS_BUF_AUTO modify DATA_DONE DATE default trunc(sysdate);
alter table UMG.SH2_VZN_ONIPS_LSV_AUTO modify DATA_DONE DATE default trunc(sysdate);
/
declare
  l_relplaces sys.odcivarchar2list := 
    sys.odcivarchar2list(
      'GAZFOND',
       'DOCLIST_PKG',
       'OFFSET pagingStart ROWS FETCH NEXT pagingSize ROWS ONLY;',
       'OFFSET to_number(pagingStart) ROWS FETCH NEXT to_number(pagingSize) ROWS ONLY;',
      'GAZFOND_PN',
       'DOCLIST_PKG',
       'OFFSET pagingStart ROWS FETCH NEXT pagingSize ROWS ONLY;',
       'OFFSET to_number(pagingStart) ROWS FETCH NEXT to_number(pagingSize) ROWS ONLY;',
      'GAZFOND',
       'DISPATCH_PLAN_PKG',
       'FETCH FIRST MAX_COUNT ROWS ONLY',
       'FETCH FIRST TO_NUMBER(MAX_COUNT) ROWS ONLY',
      'GAZFOND_PN',
       'DISPATCH_PLAN_PKG',
       'FETCH FIRST MAX_COUNT ROWS ONLY',
       'FETCH FIRST TO_NUMBER(MAX_COUNT) ROWS ONLY',
      'SASHA',
       'FIRSTPAY_REGISTER',
       'offset nvl(pStart,0) rows',
       'offset nvl(to_number(pStart) ,0) rows',
      'SASHA',
       'FIRSTPAY_REGISTER',
       'fetch first nvl(pLimit,nLimit) rows only; ',
       'fetch first nvl(to_number(pLimit), to_number(nLimit)) rows only; ',
      'GAZFOND_PN',
       'PAY_OPSREG1_PKG',
       'offset nvl(pStart,0) rows',
       'offset nvl(to_number(pStart) ,0) rows',
      'GAZFOND_PN',
       'PAY_OPSREG1_PKG',
       'fetch first nvl(pLimit,nLimit) rows only;',
       'fetch first nvl(to_number(pLimit), to_number(nLimit)) rows only;'
    );
  l_ddl clob;
  l_idx int;
  
  function get_status(p_owner varchar2, p_name varchar2) return varchar2 is
    l_status all_objects.status%type;
  begin
    select o.status
    into   l_status
    from   all_objects o
    where  o.owner = p_owner
    and    o.object_name = p_name
    and    o.object_type = 'PACKAGE BODY';
    return l_status;
  exception
    when no_data_found then
      return 'NOTFOUND';
  end get_status;
  
begin
  for i in 1..l_relplaces.count/4 loop
    case get_status(l_relplaces((i - 1) * 4 + 1), l_relplaces((i - 1) * 4 + 2))
      when 'NOTFOUND' then
        l_ddl := '';
      else
        l_ddl := replace(
          replace(
            dbms_metadata.get_ddl(
              'PACKAGE_BODY',
              l_relplaces((i - 1) * 4 + 2),
              l_relplaces((i - 1) * 4 + 1)
            ),
            l_relplaces((i - 1) * 4 + 3),
            l_relplaces((i - 1) * 4 + 4)
          ),
          'CREATE OR REPLACE EDITIONABLE PACKAGE',
          'CREATE OR REPLACE PACKAGE'
        );
    end case;
    
    begin
      if dbms_lob.getlength(l_ddl) > 0 then
        execute immediate l_ddl;
      end if;
    exception
      when others then
        dbms_output.put_line('Compile package body ' || l_relplaces((i - 1) * 4 + 1) || '.' || l_relplaces((i - 1) * 4 + 2) || ' failed: ' || sqlerrm);
    end;
  end loop;
end;
/
begin
  for t in (
    select t.tablespace_name
    from   dba_tablespaces t
    where  t.tablespace_name not in ('SYSTEM', 'SYSAUX', 'TEMP')
  ) loop
    execute immediate 'alter tablespace ' || t.tablespace_name || ' read only';
  end loop;
end;
/
CREATE OR REPLACE DIRECTORY data_dump_dir AS '&dump_dir'
/
ALTER DATABASE dataFILE '/ora1/dat/tstdb/dbs/system01.dbf' RESIZE 11G
/
exit success