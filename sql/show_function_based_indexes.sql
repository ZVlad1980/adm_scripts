with w_users as (
  select /*+ materialize*/ username
  from   all_users u
  where  u.common <> 'YES'
)
select di.owner,
       di.index_name,
       di.index_type,
       e.column_expression
from   w_users u,
       dba_indexes di,
       dba_ind_expressions e
where  1=1
and    e.index_name = di.index_name
and    e.index_owner = di.owner
and    di.index_type like 'FUNCTION-BASED%'
and    di.owner = u.username

