--https://docs.oracle.com/database/121/TGSQL/tgsql_statscon.htm#GUID-AEE74FB8-98BD-416B-8EA0-32CD605DF64E
/*
Table statistics
  Number of rows
  Number of blocks
  Average row length

Column statistics
  Number of distinct values (NDV) in a column
  Number of nulls in a column
  Data distribution (histogram)
  Extended statistics

Index statistics
  Number of leaf blocks
  Number of levels
  Index clustering factor

System statistics
  I/O performance and utilization
  CPU performance and utilization
*/
select num_rows,
       avg_row_len,
       blocks,
       last_analyzed
from   dba_tab_statistics
where  owner = 'SH'
and    table_name = 'CUSTOMERS'
;
select tcs.column_name, tcs.num_distinct, tcs.num_nulls, tcs.num_buckets, tcs.density, tcs.avg_col_len
from   dba_tab_col_statistics tcs
where  owner = 'SH'
and    table_name = 'CUSTOMERS'
;
select *
from   dba_tab_histograms th
where  owner = 'SH'
and    table_name = 'CUSTOMERS'
order by th.column_name
;
select index_name,
       blevel,
       leaf_blocks             as "LEAFBLK",
       distinct_keys           as "DIST_KEY",
       avg_leaf_blocks_per_key as "LEAFBLK_PER_KEY",
       avg_data_blocks_per_key as "DATABLK_PER_KEY"
from   dba_ind_statistics
where  owner = 'SH'
and    index_name in ('CUST_LNAME_IX', 'CUSTOMERS_PK')
;
