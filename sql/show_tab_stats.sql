select ue.segment_name,
       round(sum(ue.bytes) / 1024 / 1024, 3) amount_mb
from   user_extents ue
group by ue.segment_name
/
select ut.last_analyzed, ut.*
from   user_tables ut
/
select *
from   user_tab_statistics ts
where  ts.table_name = 'AUDIENCE'
/
select *
from   user_tab_columns utc
where   utc.table_name = 'AUDIENCE'
/
select *
from   user_tab_col_statistics tcs
where  tcs.table_name = 'AUDIENCE'
/
select *
from   user_tab_histograms th
where  th.table_name = 'AUDIENCE'
/
--удаление гистограмм
BEGIN
   dbms_stats.delete_column_stats(
         ownname=>user, tabname=>'AUDIENCE', colname=>'MONTH_NO',
                                  col_stat_type=>'HISTOGRAM');
END;
--отключение сбора гистограм по столбцу
BEGIN
   dbms_stats.set_table_prefs(user, 'AUDIENCE',
   'METHOD_OPT', 
   'FOR ALL COLUMNS SIZE AUTO, FOR COLUMNS SIZE 1 MONTH_NO');
END;
/
--без сбора гистограмм
begin
  dbms_stats.gather_table_stats(user, 'AUDIENCE', method_opt => 'FOR ALL COLUMNS SIZE AUTO, FOR COLUMNS SIZE 1 MONTH_NO', cascade => true); 
end;
