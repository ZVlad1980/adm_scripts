select do.object_name, dtc.column_name, cu.*
from   SYS.COL_USAGE$ cu,
       dba_objects    do,
       dba_tab_cols   dtc
where  do.object_id = cu.obj#
and    do.owner = 'GAZFOND'
and    dtc.column_id = cu.intcol#
