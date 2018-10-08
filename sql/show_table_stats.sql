with w_tablespaces as (
  select ut.table_name,
         uts.tablespace_name,
         uts.block_size
  from   user_tables      ut,
         user_tablespaces uts
  where  uts.tablespace_name = ut.tablespace_name
)
select ts.object_type,
       ts.table_name,
       ts.num_rows,
       ts.blocks,
       (
         ts.blocks * (
           select max(tbs.block_size)
           from   w_tablespaces tbs
           where  tbs.table_name = ts.table_name
         ) / 1024 / 1024
       ) size_mb,
       ts.avg_row_len,
       ts.sample_size,
       ts.last_analyzed
from   user_tab_statistics ts
where  ts.table_name = 'DV_SR_LSPV'
/
