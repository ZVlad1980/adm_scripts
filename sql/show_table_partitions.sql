select *
from   user_part_tables
/
select *
from   user_tab_partitions
/
select *
from   user_tab_subpartitions
/
select count(1)
from   assignments partition(P_PENSION)
