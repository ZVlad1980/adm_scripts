create table tts_log_t(
  message     varchar2(500),
  error       varchar2(4000),
  created_at  timestamp default systimestamp
)
/
create table tts_invalids_t(
  owner          varchar2(128),
  object_type    varchar2(32),
  object_name    varchar2(128),
  status         varchar2(7),
  last_ddl_time  date
)
/
create table tts_xml_columns_t(
  owner          varchar2(128),
  table_name     varchar2(128),
  column_name    varchar2(128),
  column_id      number,
  data_type      varchar2(128)
)
/
