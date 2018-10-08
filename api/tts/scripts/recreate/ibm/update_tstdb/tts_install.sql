connect system/"17trhtnC.cntv"@tstdb
create table vbz.tts_invalids_t(
  owner          varchar2(128),
  object_type    varchar2(32),
  object_name    varchar2(128),
  status         varchar2(7),
  last_ddl_time  date
);
exit;
