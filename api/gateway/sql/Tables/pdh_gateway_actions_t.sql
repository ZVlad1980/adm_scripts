create sequence pdh_gateway_actions_seq order nocache
/
create table pdh_gateway_actions_t (
  id               int 
    constraint pdh_gateway_actions_pk primary key
    using index tablespace PDH_INDX,
  fk_module_id     int not null,
  action_name      varchar2(30) not null,
  owner            varchar2(30) not null,
  unit_name        varchar2(30) not null,
  routine_name     varchar2(30) not null,
  created_at       date         default sysdate,
  constraint pdh_gateway_act_mod_fk foreign key (fk_module_id)
    references pdh_gateway_modules_t(id),
  constraint pdh_gateway_act_unq unique (fk_module_id, action_name)
    using index tablespace PDH_INDX
)
/
create index pdh_gateway_actions_ix on pdh_gateway_actions_t(fk_module_id)
  tablespace PDH_INDX
/
