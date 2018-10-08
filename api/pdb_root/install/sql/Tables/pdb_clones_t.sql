create sequence pdb_clones_seq start with 1 order nocache
/
create table pdb_clones_t(
  id             int
    default pdb_clones_seq.nextval
    constraint pdb_clones_pk primary key,
  pdb_name       varchar2(32) not null,
  pdb_parent     varchar2(32),
  open_mode      varchar2(32),
  refreshable    varchar2(20)
    default      'NO'
    constraint   pdb_clone_refrsh_chk check (refreshable in ('NO', 'DAILY', 'UPDATE_PARENT')),
  freeze         varchar2(3)
    default      'NO'
    constraint   pdb_clone_freeze_chk check (freeze in ('YES', 'NO')),
  before_action  varchar2(256),
  after_action   varchar2(256),
  pdb_created    date,
  default_parent varchar2(3),
  last_open_mode varchar2(32),
  creator        varchar2(32) default user,
  created_at     timestamp default systimestamp,
  updated_at     timestamp default systimestamp,
  constraint clone_pdbs_name_unq unique (pdb_name),
  constraint pdb_clone_parent_fk foreign key (pdb_parent) references pdb_clones_t(pdb_name)
)
/
create unique index pdb_clones_dflt_ux on pdb_clones_t(case when default_parent = 'YES' then default_parent end)
/
/*
alter table pdb_clones_t add THIN_CLONE varchar2(3) default 'YES' check (thin_clone in ('YES', 'NO')) not null
/
alter table pdb_clones_t add ACFS_PATH varchar2(512)
/
*/
