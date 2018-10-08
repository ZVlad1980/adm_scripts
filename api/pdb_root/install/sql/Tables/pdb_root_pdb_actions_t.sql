create sequence pdb_actions_seq start with 1 order nocache
/
create table pdb_actions_t(
  id int
    default pdb_actions_seq.nextval
    constraint pdb_actions_pk primary key,
  action     varchar2(30),
  pdb_name   varchar2(32) not null,
  pdb_parent varchar2(32),
  planned_at date default sysdate,
  status     varchar2(20) default 'NEW',   --NEW/SUCCESS/ERROR/PROCESS
  pdb_path   varchar2(1024),
  critical   varchar2(1),    --Y/N
  result     varchar2(4000), --error message
  created_at timestamp default systimestamp,
  updated_at timestamp default systimestamp,
  start_process timestamp,
  end_process   timestamp
)
/
create index pdb_actions_new_ix on pdb_actions_t(case when status in 'NEW' then status end)
/
create unique index pdb_actions_ux on pdb_actions_t(action, pdb_name, case when status in 'NEW' then status else to_char(id) end)
/
/*
alter table pdb_actions_t add start_process timestamp;
alter table pdb_actions_t add end_process   timestamp;
*/
