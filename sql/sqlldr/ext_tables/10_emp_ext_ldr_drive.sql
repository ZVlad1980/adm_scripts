drop table emp_ext;
create table emp_ext(
  EMPNO         varchar2(4), --NUMBER(4,0) NOT NULL ENABLE, 
  ENAME         varchar2(10), --CHAR(10), 
  JOB           varchar2(9), --CHAR(9), 
  MGR           varchar2(4), --NUMBER(4,0), 
  HIREDATE      DATE, --varchar2(10), --
  SAL           varchar2(15), --NUMBER(7,2), 
  COMM          varchar2(15), --NUMBER(7,2), 
  DEPTNO        varchar2(2), --NUMBER(2,0), 
  PROJNO        varchar2(10), --NUMBER, 
	LOADSEQ       varchar2(10) --NUMBER
) organization external(
 type oracle_loader default directory ext_tables_dir
 access parameters (
   fields terminated by ";" OPTIONALLY ENCLOSED BY '"' LDRTRIM date_format date mask "dd.mm.yyyy"
   all fields override
   reject rows with all null fields
 )
 location ('emp.tbl')
)
/*

   (
     hiredate char(10) date_format date mask "dd.mm.yyyy"--,     sal CHAR TERMINATED BY WHITESPACE char "to_number(:sal, '9999999,99')"
   )
*/
/
select *
from   emp_ext
