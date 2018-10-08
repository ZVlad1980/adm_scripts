create or replace package body tts_api is
  
  C_UNIT_NAME constant varchar2(32) := $$PLSQL_UNIT;
  
  type g_error_rec_typ is record (
    exists            int,
    error_msg         varchar2(4000),
    critical          boolean,
    error_stack       varchar2(2000),
    error_backtrace   varchar2(2000),
    call_stack        varchar2(2000)
  );
  g_error g_error_rec_typ;
  
  g_output_lines int := 0;
  
  procedure plog(p_msg varchar2, p_oel boolean default true) is
  begin
    if g_output_lines > 10000 then
      return;
    end if;
    
    g_output_lines := g_output_lines + 1;
    if p_oel then
      dbms_output.put_line(p_msg);
    else
      dbms_output.put(p_msg);
    end if;
  end;
  ----------------------------------------------------------------------------------------
  --
  ----------------------------------------------------------------------------------------
  
  procedure put_log(
    p_msg   varchar2 default null,
    p_error g_error_rec_typ default null
  ) is
    pragma autonomous_transaction;
    l_error varchar2(4000);
    procedure append_error_(p_name varchar2, p_msg varchar2) is
    begin
      l_error := l_error || case when l_error is not null then chr(10) end
        || p_name || ': ' || substr(p_msg, 1, 1000) || chr(10);
    end;
  begin
    
    if p_error.exists is not null then
      append_error_('Error msg', p_error.error_msg);
      append_error_('Error stack', p_error.error_stack);
      append_error_('Error backtrace', p_error.error_backtrace);
      append_error_('Call stack', p_error.call_stack);
    end if;
    
    insert into vbz.tts_log_t(
      message,
      error
    ) values (
      C_UNIT_NAME || ': ' || nvl(p_msg, p_error.error_msg),
      l_error
    );
    
    commit;
    
    plog(p_msg);
    
    if l_error is not null then
      plog(l_error);
    end if;

  exception
    when others then
      rollback;
  end put_log;
  
  procedure fix_exception(
    p_line int,
    p_msg  varchar2 default null,
    p_critical boolean default false
  ) is
    l_error g_error_rec_typ;
  begin
    
    l_error.exists          := 1;
    l_error.error_msg       := C_UNIT_NAME || '(' || p_line || '): ' || nvl(p_msg, sqlerrm);
    l_error.critical        := p_critical;
    l_error.error_stack     := dbms_utility.format_error_stack;
    l_error.error_backtrace := dbms_utility.format_error_backtrace;
    l_error.call_stack      := dbms_utility.format_call_stack;
    
    put_log(p_error => l_error);
    
    if g_error.exists is null then
      g_error.exists          := 1;
      g_error.error_msg       := l_error.error_msg      ;
      g_error.critical        := l_error.critical       ;
      g_error.error_stack     := l_error.error_stack    ;
      g_error.error_backtrace := l_error.error_backtrace;
      g_error.call_stack      := l_error.call_stack     ;
    end if;
    
  end fix_exception;
  
  function get_error_msg return varchar2 is
  begin
    return case when g_error.exists is null then null else g_error.error_msg end;
  end get_error_msg;
  
  function is_critical_error return boolean is
  begin
    return case when g_error.exists is null then false else g_error.critical end;
  end is_critical_error;
  
  procedure purge_error is
  begin
    g_error.exists := null;
  end purge_error;
  
  ----------------------------------------------------------------------------------------
  -- !!!!!!!!!!!!!!
  ----------------------------------------------------------------------------------------
  
  procedure ei(p_cmd varchar2) is
  begin
    execute immediate p_cmd;
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'Execute: ' || p_cmd);
      raise;
  end;
  
  /**
   * Процедура заполняет список инвалидный объектов исходной базы (для исключения из перекомпиляции после транспорта)
   */
  procedure insert_invalids is
    l_dummy int;
  begin
    --execute immediate 'truncate table tts_invalids_t';
    begin
      select 1
      into   l_dummy
      from   tts_invalids_t inv
      where  rownum = 1;
      put_log('Фиксация инвалидов пропущена. В таблице tts_invalids_t уже есть записи об инвалидных объектах.');
    exception
      when no_data_found then
        insert into tts_invalids_t(
          owner,
          object_type,
          object_name,
          status,
          last_ddl_time
        ) select ao.owner,
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
        put_log('В таблицу tts_invalids_t записаны данные о ' || sql%rowcount || ' инвалидных объектах');
        commit;
    end;
  exception
    when others then
      fix_exception($$PLSQL_LINE);
      raise;
  end insert_invalids;
  
  /**
   * Конвертация колонок из XML_TYPE в CLOB
   *  Сконвертированные колонки пишутся в 
  /
  procedure convert_xml is
    
    l_dummy int;
    
    
    procedure insert_xml_columns_ is
    begin
      --execute immediate 'truncate table tts_xml_columns_t';
      begin
        select 1
        into   l_dummy
        from   tts_xml_columns_t x
        where  rownum = 1;
        put_log('Формирование списка XML колонок пропущено. В таблице tts_xml_columns_t уже есть записи');
      exception
        when no_data_found then
          insert into tts_xml_columns_t(
            owner,
            table_name,
            column_name,
            column_id,
            column_name_clob,
            data_type
          ) with w_users as (
              select /*+ materialize/ username
              from   all_users u
              where  u.common <> 'YES'
            )
            select tc.owner,
                   tc.table_name, 
                   tc.column_name, 
                   tc.column_id,
                   upper('clob$tts_' || lpad(to_char(tc.column_id), 2, '0')),
                   tc.data_type
            from   w_users u,
                   all_tab_cols tc
            where  1=1
            and    tc.data_type = 'XMLTYPE'
            and    tc.table_name in (
                     select t.table_name
                     from   all_tables t
                     where  t.owner = u.username
                   )
            and    tc.owner = u.username;
          commit;
      end;
    exception
      when others then
        fix_exception($$PLSQL_LINE);
        raise;
    end insert_xml_columns_;
    
    procedure convert_xml_columns_ is
    begin
      for c in (
          select x.owner || '.' || x.table_name table_name,
                 x.column_name,
                 column_name_clob,
                 x.data_type
          from   tts_xml_columns_t x,
                 all_tab_cols      tc
          where  tc.owner = x.owner
          and    tc.table_name = x.table_name
          and    tc.column_name = x.column_name
          and    tc.data_type = x.data_type
        ) loop
        --
        ei('alter table ' || c.table_name || ' add ' || c.column_name_clob || ' clob');
        ei('update ' || c.table_name || ' set ' || c.column_name_clob || ' = xmltype.getClobVal(' || c.column_name || ')');
        ei('alter table ' || c.table_name || ' drop column ' || c.column_name);
        --
      end loop;
    exception
      when others then
        fix_exception($$PLSQL_LINE);
        raise;
    end convert_xml_columns_;
    
  begin
    insert_xml_columns_;
    convert_xml_columns_;
  exception
    when others then
      fix_exception($$PLSQL_LINE);
      raise;
  end convert_xml;
  
  /**
   * Конвертация колонок из XML_TYPE в CLOB
   *  Сконвертированные колонки пишутся в 
   /
  procedure repair_xml is    
  begin
    for c in (
        select x.owner || '.' || x.table_name table_name,
               x.column_name,
               x.column_name_clob,
               x.data_type
        from   tts_xml_columns_t x,
               all_tab_cols      tc
        where  tc.owner = x.owner
        and    tc.table_name = x.table_name
        and    tc.column_name = upper(x.column_name_clob)
        and    tc.data_type = 'CLOB' --x.data_type
      ) loop
      --
      ei('alter table ' || c.table_name || ' add ' || c.column_name || ' xmltype');
      ei('update ' || c.table_name || ' set ' || c.column_name || ' = xmltype.createXML(' || c.column_name_clob || ')');
      ei('alter table ' || c.table_name || ' drop column ' || c.column_name_clob);
      --
    end loop;
  exception
    when others then
      fix_exception($$PLSQL_LINE);
      raise;
  end repair_xml;
  */
  /**
   * Формирование списка функциональных индексов и удаление их
   */
  procedure drop_fn_indexes is
    procedure ei_(p_cmd varchar2) is
    begin
      ei(p_cmd);
    exception
      when others then
        purge_error;
    end;
  begin
    
    ei_('drop index bna.IDX_KPPPSW_DEPT');
    ei_('drop index fnd.IDX_IZM_REF_MEM');
    ei_('drop index fnd.IDX_NUM_VAL');
    ei_('drop index fnd.IDX_REG_DOC_FN_ISH');
    ei_('drop index fnd.IDX_SVID_DATNOMDOG');
    ei_('drop table VBZ.DV_SR_LSPV_CORRECTION_T');
    ei_('drop function fnd.OPS_ADD_DOGOVOR_DATA_MDM');
    ei_('drop function fnd.OPS_ADD_ZAYAV_DATA_MDM');
    
    ei_('drop type FND.ER_REFCURSOR');
    ei_('drop type FND.TRANS_T');
    ei_('drop type FND.ASSIGNMENT_TAB');

    ei_('drop type GAZFOND.T_INP_ROW1');
    
    ei_('drop index gazfond.DOCUMENT_REGDEPTACTNUM_IDX');
    ei_('alter table gazfond.documents drop column REG_DEPT_NUM_FOR_SORT');
    ei_('alter table gazfond.documents drop column REG_ACT_NUM_FOR_SORT');
    ei_('alter table gazfond.documents drop column REG_DOC_NUM_FOR_SORT');
    ei_('drop index gazfond_pn.DOCUMENT_REGDEPTACTNUM_IDX');
    ei_('alter table gazfond_pn.documents drop column REG_DEPT_NUM_FOR_SORT');
    ei_('alter table gazfond_pn.documents drop column REG_ACT_NUM_FOR_SORT');
    ei_('alter table gazfond_pn.documents drop column REG_DOC_NUM_FOR_SORT');
    ei_('drop index gazfond.DOC_COPY_REGDEPTACTNUM_IDX');
    ei_('alter table gazfond.doc_copy drop column REG_DEPT_NUM_FOR_SORT');
    ei_('alter table gazfond.doc_copy drop column REG_ACT_NUM_FOR_SORT');
    ei_('alter table gazfond.doc_copy drop column REG_DOC_NUM_FOR_SORT');
    ei_('drop index gazfond_pn.DOC_COPY_REGDEPTACTNUM_IDX');
    ei_('alter table gazfond_pn.doc_copy drop column REG_DEPT_NUM_FOR_SORT');
    ei_('alter table gazfond_pn.doc_copy drop column REG_ACT_NUM_FOR_SORT');
    ei_('alter table gazfond_pn.doc_copy drop column REG_DOC_NUM_FOR_SORT');
    

  exception
    when others then
      fix_exception($$PLSQL_LINE);
      raise;
  end drop_fn_indexes;
  
  /**
   * Формирование списка функциональных индексов и удаление их
   */
  procedure create_fn_indexes is
    procedure ei_(p_cmd varchar2) is
    begin
      ei(p_cmd);
    exception
      when others then
        purge_error;
    end;
  begin
    
    
    ei_('alter table gazfond.documents add REG_DEPT_NUM_FOR_SORT VARCHAR2(14) GENERATED ALWAYS AS (COALESCE(LPAD(REG_DEPT_NUM,14,''0''),''00000000000000'')) VIRTUAL  NOT NULL ENABLE');
    ei_('alter table gazfond.documents add REG_ACT_NUM_FOR_SORT VARCHAR2(14) GENERATED ALWAYS AS (COALESCE(LPAD(REG_ACT_NUM,14,''0''),''00000000000000'')) VIRTUAL  NOT NULL ENABLE');
    ei_('alter table gazfond.documents add REG_DOC_NUM_FOR_SORT VARCHAR2(14) GENERATED ALWAYS AS (COALESCE(LPAD(REG_DOC_NUM,14,''0''),''00000000000000'')) VIRTUAL  NOT NULL ENABLE');
    ei_('alter table gazfond_pn.documents add REG_DEPT_NUM_FOR_SORT VARCHAR2(14) GENERATED ALWAYS AS (COALESCE(LPAD(REG_DEPT_NUM,14,''0''),''00000000000000'')) VIRTUAL  NOT NULL ENABLE');
    ei_('alter table gazfond_pn.documents add REG_ACT_NUM_FOR_SORT VARCHAR2(14) GENERATED ALWAYS AS (COALESCE(LPAD(REG_ACT_NUM,14,''0''),''00000000000000'')) VIRTUAL  NOT NULL ENABLE');
    ei_('alter table gazfond_pn.documents add REG_DOC_NUM_FOR_SORT VARCHAR2(14) GENERATED ALWAYS AS (COALESCE(LPAD(REG_DOC_NUM,14,''0''),''00000000000000'')) VIRTUAL  NOT NULL ENABLE');
    
    ei_('alter table gazfond.doc_copy add REG_DEPT_NUM_FOR_SORT VARCHAR2(14) GENERATED ALWAYS AS (COALESCE(LPAD(REG_DEPT_NUM,14,''0''),''00000000000000'')) VIRTUAL  NOT NULL ENABLE');
    ei_('alter table gazfond.doc_copy add REG_ACT_NUM_FOR_SORT VARCHAR2(14) GENERATED ALWAYS AS (COALESCE(LPAD(REG_ACT_NUM,14,''0''),''00000000000000'')) VIRTUAL  NOT NULL ENABLE');
    ei_('alter table gazfond.doc_copy add REG_DOC_NUM_FOR_SORT VARCHAR2(14) GENERATED ALWAYS AS (COALESCE(LPAD(REG_DOC_NUM,14,''0''),''00000000000000'')) VIRTUAL  NOT NULL ENABLE');
    ei_('alter table gazfond_pn.doc_copy add REG_DEPT_NUM_FOR_SORT VARCHAR2(14) GENERATED ALWAYS AS (COALESCE(LPAD(REG_DEPT_NUM,14,''0''),''00000000000000'')) VIRTUAL  NOT NULL ENABLE');
    ei_('alter table gazfond_pn.doc_copy add REG_ACT_NUM_FOR_SORT VARCHAR2(14) GENERATED ALWAYS AS (COALESCE(LPAD(REG_ACT_NUM,14,''0''),''00000000000000'')) VIRTUAL  NOT NULL ENABLE');
    ei_('alter table gazfond_pn.doc_copy add REG_DOC_NUM_FOR_SORT VARCHAR2(14) GENERATED ALWAYS AS (COALESCE(LPAD(REG_DOC_NUM,14,''0''),''00000000000000'')) VIRTUAL  NOT NULL ENABLE');
    
    ei_('CREATE INDEX BNA.IDX_KPPPSW_DEPT ON BNA.KPP_PASS (BNA.KPP_GET_DEPT(ID)) PARALLEL 5');
    ei_('CREATE INDEX FND.IDX_IZM_REF_MEM ON FND.IZMENENIYA (FND.IZM_REFERS_MEMBER(KOD_IZM))  PARALLEL 5');
    ei_('CREATE INDEX FND.IDX_NUM_VAL ON FND.IZM_KEY_VAL (FND.SAFE_TO_NUMBER(VAL))  PARALLEL 5');
    ei_('CREATE INDEX FND.IDX_REG_DOC_FN_ISH ON FND.REG_DOC_INSZ (FND.REG_GET_DOC_ISH(KOD_INSZ))  PARALLEL 5');
    ei_('CREATE INDEX FND.IDX_SVID_DATNOMDOG ON FND.DOC_SVID (FND.SVID_GET_DATA_NOM_DOG(DATA_DOG,NOM_DOG)) PARALLEL 5');
    --
    ei_('CREATE INDEX GAZFOND.DOCUMENT_REGDEPTACTNUM_IDX ON GAZFOND.DOCUMENTS (REG_DEPT_NUM_FOR_SORT, REG_ACT_NUM_FOR_SORT, REG_DOC_NUM_FOR_SORT)  PARALLEL 5');
    ei_('CREATE INDEX GAZFOND.DOC_COPY_REGDEPTACTNUM_IDX ON GAZFOND.DOC_COPY (REG_DEPT_NUM_FOR_SORT, REG_ACT_NUM_FOR_SORT, REG_DOC_NUM_FOR_SORT)  PARALLEL 5');
    ei_('CREATE INDEX GAZFOND_PN.DOCUMENT_REGDEPTACTNUM_IDX ON GAZFOND_PN.DOCUMENTS (REG_DEPT_NUM_FOR_SORT, REG_ACT_NUM_FOR_SORT, REG_DOC_NUM_FOR_SORT)  PARALLEL 5');
    ei_('CREATE INDEX GAZFOND_PN.DOC_COPY_REGDEPTACTNUM_IDX ON GAZFOND_PN.DOC_COPY (REG_DEPT_NUM_FOR_SORT, REG_ACT_NUM_FOR_SORT, REG_DOC_NUM_FOR_SORT)  PARALLEL 5');
    
    /*ei_('CREATE INDEX GAZFOND.DOCUMENT_ACTION_FDONE_IDX ON GAZFOND.DOCUMENTS (DECODE(TO_CHAR(FK_DONE),NULL,0,1)) PARALLEL 5');
    
    ei_('CREATE INDEX GAZFOND.DOCUMENT_LOWER_TITLE_IDX ON GAZFOND.DOCUMENTS (LOWER(TITLE))  PARALLEL 5');
    ei_('CREATE INDEX GAZFOND.DOCUMENT_TRANC_DATE ON GAZFOND.DOCUMENTS (TRUNC(DOC_DATE))  PARALLEL 5');
    
    ei_('CREATE INDEX GAZFOND.DOC_COPY_TRANC_DATE ON GAZFOND.DOC_COPY (TRUNC(DOC_DATE))  PARALLEL 5');
    ei_('CREATE INDEX GAZFOND.DOC_COPY_LOWER_TITLE_IDX ON GAZFOND.DOC_COPY (LOWER(TITLE))  PARALLEL 5');
    
    ei_('CREATE INDEX GAZFOND_PN.DOCUMENT_ACTION_FDONE_IDX ON GAZFOND_PN.DOCUMENTS (DECODE(TO_CHAR(FK_DONE),NULL,0,1))  PARALLEL 5');
    ei_('CREATE INDEX GAZFOND_PN.DOCUMENT_LOWER_TITLE_IDX ON GAZFOND_PN.DOCUMENTS (LOWER(TITLE))  PARALLEL 5');
    ei_('CREATE INDEX GAZFOND_PN.DOCUMENT_TRANC_DATE ON GAZFOND_PN.DOCUMENTS (TRUNC(DOC_DATE))  PARALLEL 5');
    ei_('CREATE INDEX GAZFOND_PN.DOC_COPY_TRANC_DATE ON GAZFOND_PN.DOC_COPY (TRUNC(DOC_DATE))  PARALLEL 5');
    ei_('CREATE INDEX GAZFOND_PN.DOC_COPY_LOWER_TITLE_IDX ON GAZFOND_PN.DOC_COPY (LOWER(TITLE))  PARALLEL 5');
    --
    ei_('alter table gazfond.documents add constraint DOCUMENT_ISDELETE_CH CHECK (ISDELETE IS NULL OR ISDELETE IN ( 0, 1))');
    ei_('alter table gazfond.documents add constraint DOCUMENT_DOC_OUT_CK CHECK (FK_DOC_OUT = CASE WHEN FK_DOC_OUT IS NOT NULL THEN ID  END)');
    ei_('alter table gazfond.documents add constraint DOCUMENT_PK PRIMARY KEY (ID)');
    ei_('alter table gazfond.documents add constraint DOCUMENT_MOTIW_UK UNIQUE ("MOTIW_ID")');
    ei_('alter table gazfond.documents add constraint DOCUMENT_OUT_UK UNIQUE ("FK_DOC_OUT")');
    ei_('alter table gazfond.doc_copy add constraint DOC_COPY_DOC_OUT_CK CHECK (FK_DOC_OUT = CASE WHEN FK_DOC_OUT IS NOT NULL THEN ID  END)');
    ei_('alter table gazfond.doc_copy add constraint DOC_COPY_ISDELETE_CH CHECK (ISDELETE IS NULL OR ISDELETE IN ( 0, 1))');
    ei_('alter table gazfond.doc_copy add constraint DOC_COPY_PK PRIMARY KEY (ID)');
    ei_('alter table gazfond.doc_copy add constraint DOC_COPY_MOTIW_UK  UNIQUE ("MOTIW_ID")');
    ei_('alter table gazfond.doc_copy add constraint DOC_COPY_OUT_UK UNIQUE ("FK_DOC_OUT")');
    --
    ei_('alter table gazfond_pn.documents add constraint DOCUMENT_ISDELETE_CH CHECK (ISDELETE IS NULL OR ISDELETE IN ( 0, 1))');
    ei_('alter table gazfond_pn.documents add constraint DOCUMENT_DOC_OUT_CK CHECK (FK_DOC_OUT = CASE WHEN FK_DOC_OUT IS NOT NULL THEN ID  END)');
    ei_('alter table gazfond_pn.documents add constraint DOCUMENT_PK PRIMARY KEY (ID)');
    ei_('alter table gazfond_pn.documents add constraint DOCUMENT_MOTIW_UK UNIQUE ("MOTIW_ID")');
    ei_('alter table gazfond_pn.documents add constraint DOCUMENT_OUT_UK UNIQUE ("FK_DOC_OUT")');
    ei_('alter table gazfond_pn.doc_copy add constraint DOC_COPY_DOC_OUT_CK CHECK (FK_DOC_OUT = CASE WHEN FK_DOC_OUT IS NOT NULL THEN ID  END)');
    ei_('alter table gazfond_pn.doc_copy add constraint DOC_COPY_ISDELETE_CH CHECK (ISDELETE IS NULL OR ISDELETE IN ( 0, 1))');
    ei_('alter table gazfond_pn.doc_copy add constraint DOC_COPY_PK PRIMARY KEY (ID)');
    ei_('alter table gazfond_pn.doc_copy add constraint DOC_COPY_MOTIW_UK  UNIQUE ("MOTIW_ID")');
    ei_('alter table gazfond_pn.doc_copy add constraint DOC_COPY_OUT_UK UNIQUE ("FK_DOC_OUT")');
    */
  exception
    when others then
      fix_exception($$PLSQL_LINE);
      raise;
  end create_fn_indexes;
  
  procedure top_n_query is
    l_relplaces sys.odcivarchar2list := 
      sys.odcivarchar2list(
        'GAZFOND',
         'DOCLIST_PKG',
         'OFFSET pagingStart ROWS FETCH NEXT pagingSize ROWS ONLY;',
         'OFFSET to_number(pagingStart) ROWS FETCH NEXT to_number(pagingSize) ROWS ONLY;',
        'GAZFOND_PN',
         'DOCLIST_PKG',
         'OFFSET pagingStart ROWS FETCH NEXT pagingSize ROWS ONLY;',
         'OFFSET to_number(pagingStart) ROWS FETCH NEXT to_number(pagingSize) ROWS ONLY;'
      );
    l_ddl clob;
    l_idx int;
    
  begin
    for i in 1..l_relplaces.count/4 loop
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
      begin
        execute immediate l_ddl;
      exception
        when others then
          fix_exception($$PLSQL_LINE, 'Compile package body ' || l_relplaces((i - 1) * 4 + 1) || '.' || l_relplaces((i - 1) * 4 + 2) || ' failed: ' || sqlerrm);
          raise;
      end;
    end loop;
  exception
    when others then
      fix_exception($$PLSQL_LINE, 'top_n_query');
      raise;
  end top_n_query;
  
  /**
   *
   */
  procedure replace_defaults is
  begin
    
    ei('alter table BNA.DATA_155 modify DATE_ZANES DATE default trunc(sysdate)');
    ei('alter table BNA.DATA_152 modify DATE_ZANES DATE default trunc(sysdate)');
    ei('alter table BNA.DATA_153 modify DATE_ZANES DATE default trunc(sysdate)');
    ei('alter table BNA.DATA_154 modify DATA_STATUS DATE default to_date(''31.03.2009'', ''dd.mm.yyyy'')');
    ei('alter table BNA.DATA_266 modify DATE_RSH DATE default to_date(''30.08.2013'', ''dd.mm.yyyy'')');
    ei('alter table BNA.DATA_272 modify DATE_SOST DATE default to_date(''15.05.2014'', ''dd.mm.yyyy'')');
    ei('alter table BNA.DATA_153 modify DATE_ZANES DATE default trunc(sysdate)');
    ei('alter table BNA.DATA_153 modify DATE_ZANES DATE default trunc(sysdate)');
    ei('alter table DWH.DWH_TBL_FIZLITS_BUFTR modify SYS_DATE DATE default trunc(sysdate)');
    ei('alter table DWH.DWH_TBL_OUTSUM_BUFTR modify SYS_DATE DATE default trunc(sysdate)');
    ei('alter table DWH.DWH_TBL_AVGPEN_BUFTR modify SYS_DATE DATE default trunc(sysdate)');
    ei('alter table MDM.OPS_REESTR_NPO_BUF modify SYS_DATE DATE default trunc(sysdate)');
    ei('alter table UMG.TBL_DWH_NV_SH2_SET modify SYS_DATE DATE default trunc(sysdate)');
    ei('alter table UMG.TBL_DWH_NV_SH2_SFL modify SYS_DATE DATE default trunc(sysdate)');
    ei('alter table UMG.TBL_DWH_NV_SH2_TTIPS modify SYS_DATE DATE default trunc(sysdate)');
    ei('alter table UMG.WEB_SP_REPORTS modify REP_DATE DATE default trunc(sysdate)');
    ei('alter table UMG.TBL_DWH_NV_SH2_DVIPS modify SYS_DATE DATE default trunc(sysdate)');
    ei('alter table UMG.APP_ZAYAV modify DATE_SYS DATE default trunc(sysdate)');
    ei('alter table UMG.SH0_VZN_REPORT_NEW modify DATA_ZANES DATE default trunc(sysdate)');
    ei('alter table UMG.SH1_VZN_ONIPS_BUF_AUTO modify DATA_DONE DATE default trunc(sysdate)');
    ei('alter table UMG.SH1_VZN_REPORT_NEW modify DATA_ZANES DATE default trunc(sysdate)');
    ei('alter table UMG.SH2_VZN_ONIPS_BUF_AUTO modify DATA_DONE DATE default trunc(sysdate)');
    ei('alter table UMG.SH2_VZN_ONIPS_LSV_AUTO modify DATA_DONE DATE default trunc(sysdate)');
    
  exception
    when others then
      fix_exception($$PLSQL_LINE);
      raise;
  end replace_defaults;
  
  /**
   */
  procedure prepare_transport_db(
    x_status    out varchar2,
    x_error_msg out varchar2
  ) is
  begin
    purge_error;
    --
    insert_invalids;
    top_n_query;
    drop_fn_indexes;
    replace_defaults;
    --
    x_status := 'SUCCESS';
  exception
    when others then
      fix_exception($$PLSQL_LINE);
      x_status := 'ERROR';
      x_error_msg := get_error_msg;
  end prepare_transport_db;
  
  
  /**
   */
  procedure compile_invalids is
    l_cmd varchar2(32767);
  
  cursor l_invalids_cur is 
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
            from   tts_invalids_t t
           ) tt
    where  tt.object_type not in ('JAVA SOURCE')      
    order by 
      case tt.object_type
        when 'PACKAGE' then 1
        when 'VIEW' then 2
        when 'SYNONYM' then 3
        else 99
      end;
   
  
begin
  --
  for i in 1..3 loop
    for o in l_invalids_cur loop
      if o.object_type in ('PACKAGE', 'TYPE') then
        l_cmd := 'alter ' || o.object_type || ' ' || o.owner || '.' || o.object_name || ' compile specification';
      elsif o.object_type in ('PACKAGE BODY', 'TYPE BODY') then
        l_cmd := 'alter ' || substr(o.object_type, 1, instr(o.object_type, ' ') - 1) || ' ' || o.owner || '.' || o.object_name || ' compile body';
      elsif o.object_type = 'JAVA CLASS' then
        l_cmd := 'alter java class "' || o.owner || '"."' || o.object_name || '" resolve;';
      else
        l_cmd := 'alter ' || o.object_type || ' ' || o.owner || '.' || o.object_name || ' compile';
      end if;
      begin
        ei(l_cmd);
      exception
        when others then
          if i = 3 then
            plog(l_cmd || ' fail.' || chr(10) || sqlerrm);
          end if;
      end;
    end loop;
  end loop;
  --
  for o in l_recomp_schemas_cur loop
    begin
      utl_recomp
    exception
      when others then
        put_log('Recomp schema ' || o.owner || ' fatal error');
    end;
  end loop;
  --
  exception
    when others then
      fix_exception($$PLSQL_LINE);
      raise;
  end compile_invalids;



  procedure reset_pwds is
    cursor l_users_cur is
      select u.username
      from   all_users u
      where  u.common = 'NO'
      and    u.username in ('GAZFOND', 'GAZFOND_PN', 'FND', 'CDM');
  begin
    for u in l_users_cur loop
      execute immediate('alter user ' || u.username || ' identified by ' || lower(u.username));
    end loop;
    --
  exception
    when others then
      fix_exception($$PLSQL_LINE);
      raise;
  end reset_pwds;
      
  /**
   */
  procedure repair_db(
    x_status    out varchar2,
    x_error_msg out varchar2
  ) is
  begin
    purge_error;
    --
    create_fn_indexes;
    compile_invalids;
    reset_pwds;
    --
    x_status := 'SUCCESS';
    --
  exception
    when others then
      fix_exception($$PLSQL_LINE);
      x_status := 'ERROR';
      x_error_msg := get_error_msg;
  end repair_db;

end tts_api;
/
