select segment_name,
       segment_type,
       bytes / 1024 / 1024 size_mb
from   dba_segments ds
where  1=1--ds.segment_type = 'INDEX'
and    (ds.owner, ds.segment_name) in (
         select upper('&owner'),upper('&table_name')
         from   dual
         union all
         select di.owner, di.index_name
         from   dba_indexes di
         where  1=1
         and    di.table_owner = upper('&owner')
         and    di.table_name = upper('&table_name')
       )
