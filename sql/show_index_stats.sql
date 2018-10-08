select *
from   user_indexes ui
where  ui.index_name = upper('&index_name') --T1_I1
/
select *,
       uis.avg_data_blocks_per_key
from   user_ind_statistics uis
where  uis.index_name = upper('&index_name')--T1_I1
/
