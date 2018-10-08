select *
from   user_tab_histograms th
where  th.table_name = '&table_name'
/
select *
from   user_part_histograms ph
where  ph.table_name = '&table_name'
/
select *
from   user_subpart_histograms ph
where  ph.table_name = '&table_name'
/
