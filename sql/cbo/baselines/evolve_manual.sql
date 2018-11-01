-- conn sys as sysdba
--Base statement
SELECT /* q1_group_by */ prod_name, sum(quantity_sold)
FROM   products p, sales s
WHERE  p.prod_id = s.prod_id
AND    p.prod_category_id =203
GROUP BY prod_name;
--
ALTER SYSTEM FLUSH SHARED_POOL;
ALTER SYSTEM FLUSH BUFFER_CACHE;
--
ALTER session SET OPTIMIZER_CAPTURE_SQL_PLAN_BASELINES=true;
--
Execute twice Base statement via sqlplus sh
--
SELECT SQL_HANDLE, SQL_TEXT, PLAN_NAME,
       ORIGIN, ENABLED, ACCEPTED, FIXED 
FROM   DBA_SQL_PLAN_BASELINES
WHERE  SQL_TEXT LIKE '%q1_group%';
--
Add indexes:
CREATE INDEX ind_prod_cat_name 
  ON products(prod_category_id, prod_name, prod_id);
CREATE INDEX ind_sales_prod_qty_sold 
  ON sales(prod_id, quantity_sold);
;
execute Base statement again
/
SELECT SQL_HANDLE, SQL_TEXT, PLAN_NAME,
       ORIGIN, ENABLED, ACCEPTED, FIXED 
FROM   DBA_SQL_PLAN_BASELINES
WHERE  SQL_TEXT LIKE '%q1_group%'
and    sql_text not like '%SQL_TEXT%'
/
--
CONNECT sys AS SYSDBA
VARIABLE cnt NUMBER
VARIABLE tk_name VARCHAR2(50)
VARIABLE exe_name VARCHAR2(50)
VARIABLE evol_out CLOB
 
EXECUTE :tk_name := DBMS_SPM.CREATE_EVOLVE_TASK(sql_handle => 'SQL_07f16c76ff893342',plan_name  => 'SQL_PLAN_0gwbcfvzskcu2ae9b4305'); 
SELECT :tk_name FROM DUAL;
EXECUTE :evol_out := DBMS_SPM.REPORT_EVOLVE_TASK( task_name=>:tk_name, execution_name=>:exe_name );
SELECT :evol_out FROM DUAL;

EXECUTE :cnt := DBMS_SPM.IMPLEMENT_EVOLVE_TASK( task_name=>:tk_name, execution_name=>:exe_name );
/
SELECT SQL_HANDLE, SQL_TEXT, PLAN_NAME, ORIGIN, ENABLED, ACCEPTED
FROM   DBA_SQL_PLAN_BASELINES
WHERE  SQL_HANDLE IN ('SQL_07f16c76ff893342')
ORDER BY SQL_HANDLE, ACCEPTED;
