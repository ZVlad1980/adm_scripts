--DBMS_SPD 
--The gather_plan_statistics hint shows the actual number of rows returned from each operation in the plan.
SELECT /*+ gather_plan_statistics*/ * 
FROM   customers 
WHERE  cust_state_province='CA' 
AND    country_id = (
select cc.country_id
from   countries cc
where cc.country_iso_code = 'US'
)
;
--from sys!!!
begin
  DBMS_SPD.FLUSH_SQL_PLAN_DIRECTIVE;
end;
/
select to_char(d.directive_id) dir_id,
       o.owner as "OWN",
       o.object_name as "OBJECT",
       o.subobject_name col_name,
       o.object_type,
       d.type,
       d.state,
       d.reason
from   dba_sql_plan_directives  d,
       dba_sql_plan_dir_objects o
where  d.directive_id = o.directive_id
and    o.owner in ('SH')
order  by 1,2,3,4,5;
