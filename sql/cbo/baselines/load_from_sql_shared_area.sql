SELECT /*LOAD_CC*/ *
FROM   sh.sales
WHERE  quantity_sold > 40
ORDER BY prod_id
;
SELECT   SQL_ID, CHILD_NUMBER AS "Child Num",
         PLAN_HASH_VALUE AS "Plan Hash",
         OPTIMIZER_ENV_HASH_VALUE AS "Opt Env Hash"
FROM     V$SQL
WHERE    SQL_TEXT LIKE 'SELECT /*LOAD_CC*/%'
;
declare
  v_plan_cnt number;
begin
v_plan_cnt := DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE(
                    sql_id => '2kj4b6jn2f145'
              );
end;
/
SELECT *
FROM   DBA_SQL_PLAN_BASELINES
where sql_text like 'SELECT /*LOAD_CC*/%'
