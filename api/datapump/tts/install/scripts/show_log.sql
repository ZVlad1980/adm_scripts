--truncate table GF_DUMP_LOG_T
select * 
from   GF_DUMP_LOG_T t
order by created_at desc, id desc
/
/*
select *
from   dp_exclude_tables_t
/
select table_owner, count(1)
from   dp_exclude_tables_t
group by table_owner
*/
