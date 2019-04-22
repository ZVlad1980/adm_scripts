declare
  l_dummy number;
begin
  select 1
  into   l_dummy
  from   user_tab_cols tc
  where  tc.table_name = 'LOG_DATA'
  and    tc.column_name = 'LOG_TYPE';
  
  execute immediate 'drop table log_data';
  execute immediate 'drop sequence log_data_sq';
  execute immediate 'drop sequence log_data_row_sq';
exception
  when no_data_found then
    null;
end;
/
create sequence log_data_sq start with 1 cache 30 order
;
create table log_data(
  log_id         number not null,
  log_num        number not null,
  module_name    varchar2(128)  default 'UNKNOWN' not null,
  action_name    varchar2(128)  default 'UNKNOWN' not null,
  message_lvl    varchar2(20)   not null,
  message        varchar2(4000),
  error_info     clob,
  created_at     timestamp default systimestamp
)
;
