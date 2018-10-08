create sequence gf_dump_log_seq start with 1 order
/
create table gf_dump_log_t(
  id                 int
    default gf_dump_log_seq.nextval
    constraint gf_dump_log_pk primary key,
  message_type       varchar2(10), --Message/Error/Warning
  message            varchar2(400),
  error_code         number,
  error_detail       clob,
  created_at         timestamp default current_timestamp
)
/
