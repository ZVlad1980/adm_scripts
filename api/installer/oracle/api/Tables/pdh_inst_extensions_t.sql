create sequence pdh_inst_extensions_seq start with 1 order nocache
/
create table pdh_inst_extensions_t(
  ext_id             int 
    constraint pdh_inst_extensions_pk 
    primary key using index tablespace PDH_INDX,
  ext_code           varchar2(100) not null
    constraint pdh_inst_extensions_unq 
    unique using index tablespace PDH_INDX,
  ext_version        varchar2(20) default '0.0.0' not null,
  commit_sha         varchar2(120),
  ext_descr          varchar2(512),
  created_date       timestamp default systimestamp,
  created_by         varchar2(100),
  last_update_date   timestamp default systimestamp
)
/
create sequence pdh_inst_extension_hist_seq start with 1 order nocache
/
create table pdh_inst_extension_hist_t(
  hist_id int constraint pdh_inst_extension_hist_pk 
    primary key using index tablespace PDH_INDX,
  ext_id int not null,
  ext_version      varchar2(20) default '0.0.0' not null,
  commit_sha       varchar2(120),
  ext_created_date timestamp default systimestamp,
  ext_created_by   varchar2(100),
  created_date     timestamp default systimestamp,
  created_by       varchar2(100)
)
/
