create or replace view log_data_v as
  select d.log_id, 
         d.log_num,
         round(
           extract(hour from d.duration) * 3600 + 
           extract(minute from d.duration) * 60 + 
           extract(second from d.duration),
           3
         ) duration_sec,
         d.module_name, 
         d.action_name, 
         d.message_lvl, 
         d.message, 
         d.error_info, 
         d.created_at,
         d.row_num,
         d.rows_total
  from   (
          select d.log_id, 
                 d.log_num, 
                 d.module_name, 
                 d.action_name, 
                 d.message_lvl, 
                 d.message, 
                 d.error_info, 
                 d.created_at,
                 d.created_at - lag(d.created_at)over(partition by d.log_id order by d.log_num) duration,
                 row_number()over(partition by d.log_id order by d.log_num) row_num,
                 count(1)over(partition by d.log_id) rows_total
          from   log_data d
         ) d
/
