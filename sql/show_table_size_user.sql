select segment_name,
       segment_type,
       ds.partition_name,
       bytes / 1024 / 1024 size_mb
from   user_segments ds
where  1 = 1 --ds.segment_type = 'INDEX'
and    (ds.segment_name) in (
         select upper('assignments')
         from   dual
         union all
         select di.index_name
         from   user_indexes di
         where  1 = 1
         and    di.table_name = upper('assignments')
       )
order by segment_type desc, size_mb
