/*
https://docs.oracle.com/database/121/TGSQL/tgsql_genplan.htm#TGSQL94700
 Check parameter STATISTICS_LEVEL
 See Also:
  - Monitoring Database Operations for information about the V$SQL_PLAN_MONITOR view (https://docs.oracle.com/database/121/TGSQL/tgsql_monit.htm#GUID-C941CE9D-97E1-42F8-91ED-4949B2B710BF)
  - Oracle Database Reference for more information about V$SQL_PLAN views(https://docs.oracle.com/database/121/REFRN/GUID-87561B21-721C-42EB-8E3D-28251C9BC50C.htm#REFRN30250)
  - Oracle Database Reference for information about the STATISTICS_LEVEL initialization parameter (https://docs.oracle.com/database/121/REFRN/GUID-16B23F95-8644-407A-A6C8-E85CADFA61FF.htm#REFRN10214)

v$sql
v$sql_plan
v$sql_plan_statistics
v$sql_plan_statistics_all
*/
select *
from   v$sql s
where  s.sql_id = '9babjv8yq8ru3' --sql_text like '%employees emp%'
/
select sp.id, sp.parent_id, 
       rpad(' ', sp.depth * 2, ' ')
         || sp.operation || ' '
         || sp.options operation, 
       case sp.id
         when 0 then
           sp.optimizer
         else
           sp.object_owner || '.' || sp.object_name || ' (' || sp.object_type || ')'
       end object_name,
       sp.cardinality,
       sp.cost || ' (' || sp.cpu_cost || ', ' || sp.io_cost|| ')' costs,
       sp.time,
       sp.access_predicates,
       sp.filter_predicates,
       sp.projection,
       sp.*
from   v$sql_plan_statistics_all sp
where  sp.sql_id = '11672wcncwa9u'
