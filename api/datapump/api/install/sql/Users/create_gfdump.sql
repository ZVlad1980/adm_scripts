--drop user gfdump cascade;
create user gfdump identified by gfdump default tablespace USERDATA quota 100M on USERDATA;
/
grant alter user to gfdump
/
GRANT resource, connect, EXP_FULL_DATABASE, IMP_FULL_DATABASE TO gfdump
/
grant create database link, create job, create table, create procedure, create view, create sequence to gfdump
/
grant create any job to gfdump
/
GRANT DEBUG ANY PROCEDURE TO gfdump
/
GRANT DEBUG CONNECT SESSION TO gfdump
/
grant drop user to gfdump
/
grant execute on dbms_lock to system with grant option
/
grant execute on dbms_lock to gfdump
/
grant execute on dbms_datapump to gfdump;
/
--grant DATAPUMP_IMP_FULL_DATABASE to gfdump
