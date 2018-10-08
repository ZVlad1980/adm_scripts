select ui.index_name,
       ui.index_type || ' ' || ui.uniqueness index_type,
       listagg(ic.column_name, ', ') within group (order by ic.column_position) cols
from   user_indexes ui,
       user_ind_columns ic
where  1=1
and    ic.index_name = ui.index_name
and    ui.table_owner = user
and    ui.table_name = 'ASSIGNMENTS'
group by ui.index_name, ui.index_type, ui.uniqueness
order by ui.index_name
/
