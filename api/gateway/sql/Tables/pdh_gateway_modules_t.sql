create sequence pdh_gateway_modules_seq order nocache
/
create table pdh_gateway_modules_t (
  id            int
    constraint pdh_gateway_modules_pk primary key
      using index tablespace PDH_INDX,
  module_name   varchar2(30) not null,
  created_at    date         default sysdate,
  description   varchar2(1024),
  constraint pdh_gateway_modules_name_unq unique (module_name)
    using index tablespace PDH_INDX
)
/
