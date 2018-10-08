/*
drop TABLE TAB1;
drop TABLE TAB2;
CREATE TABLE TAB1(
  EMPNO NUMBER(4,0),
  ENAME VARCHAR2(10),
  JOB VARCHAR2(9),
  DEPTNO NUMBER(2,0)
);
CREATE TABLE TAB2(
  EMPNO NUMBER(4,0),
  ENAME VARCHAR2(10),
  JOB VARCHAR2(9),
  DEPTNO NUMBER(2,0)
);
*/
/*
CREATE TABLE TAB2(
  EMPNO NUMBER(4,0) PRIMARY KEY ENABLE,
  ENAME VARCHAR2(20),
  MGR NUMBER(4,0),
  DEPTNO NUMBER(2,0)
)
/
drop trigger tab1
*/
/*
create index tab1_ix1 on tab1(job);
alter table tab1 add constraint tab1_DEPTNO_chk check (deptno < 1000)
*/
select *
from   tab1
/
select *
from   user_objects o
where  o.object_name in ('TAB1', 'TAB2')
