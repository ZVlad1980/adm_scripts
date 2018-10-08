create table dp_exclude_tables_t(
  table_owner  varchar2(32),
  table_name   varchar2(32),
  exclude_type varchar2(1) default null
    constraint dp_exclude_tables_type_chk
      check (exclude_type in 'F')
)
/
