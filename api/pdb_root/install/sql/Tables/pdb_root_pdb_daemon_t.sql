create sequence pdb_daemon_seq start with 1 order nocache
/
create table pdb_daemon_t(
  id int
    default pdb_daemon_seq.nextval
    constraint pdb_daemon_pk primary key,
  status                varchar2(10) not null, --START/STOP
  state                 varchar2(10) not null, --EXECUTE/CRITICAL/MAINTENANCE/STOPPED
  start_time            timestamp default systimestamp,
  stop_time             timestamp,
  last_execute          timestamp,
  critical_time         timestamp,
  critical_action_id    int
)
/
create unique index pdb_daemon_ux on pdb_daemon_t(case when status = 'START' then status end)
/
