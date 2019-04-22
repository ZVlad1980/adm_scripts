create sequence pdh_gateway_parameters_seq order nocache
/
create table pdh_gateway_parameters_t (
  id               int
    constraint pdh_gateway_parameters_pk primary key
    using index tablespace pdh_indx,
  fk_action_id     int not null,
  parameter_name   varchar2(30)  not null,
  parameter_dir    varchar2(6)   default 'IN' not null constraint pdh_gateway_pars_dir_chk check (parameter_dir in ('IN', 'OUT', 'IN OUT')),
  parameter_type   varchar2(106) default 'VARCHAR2' not null,
  constraint pdh_gateway_pars_act_fk foreign key (fk_action_id)
    references pdh_gateway_actions_t(id),
  constraint pdh_gateway_pars_unq unique (fk_action_id, parameter_name)
    using index tablespace PDH_INDX
)
/
create index pdh_gateway_parameters_ix on pdh_gateway_parameters_t(fk_action_id)
  tablespace PDH_INDX
/
