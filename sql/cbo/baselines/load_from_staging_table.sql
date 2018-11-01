--create staging_table
BEGIN
  DBMS_SPM.CREATE_STGTAB_BASELINE (
    table_name => 'stage1');
END;
/
SELECT *
FROM   DBA_SQL_PLAN_BASELINES spb
where  spb.creator = 'NODE'
/
DECLARE
  v_plan_cnt NUMBER;
BEGIN
  v_plan_cnt := DBMS_SPM.PACK_STGTAB_BASELINE (
    table_name => 'stage1'
,   enabled    => 'yes'
,   creator    => 'NODE'
,   sql_handle => 'SQL_f6cb7f742ef93547'
);
END;
/
select *
from   stage1 
/
--export to dump file, transfer and import to target db 
--after load:
DECLARE
  v_plan_cnt NUMBER;
BEGIN
  v_plan_cnt := DBMS_SPM.UNPACK_STGTAB_BASELINE (
    table_name => 'stage1'
,   fixed      => 'yes'
);
END;
/
