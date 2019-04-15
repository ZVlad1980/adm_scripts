select segment_name,
       segment_type,
       bytes / 1024 / 1024 size_mb
from   user_segments ds,
       table(sys.odcivarchar2list(
         'C_STG_NAGE_PROD_FMLY_EDISN_HIS',
         'C_STG_JPCMS_PBLN_JPCMS_HIST',
         'C_STG_GOI_PVBJCPP_HIST_OCT29'
       )) t
where  1=1
and    ds.segment_name = t.column_value
and    /*in (
         select upper('&table_name')
         from   dual
         union all
         select di.index_name
         from   dba_indexes di
         where  1=1
         --and    di.table_owner = upper('&owner')
         and    di.table_name = upper('&table_name')
       )
--*/
