set pagesize 80
set linesize 120
set echo off

def _PDH_NAME=&1
def _PDH_PWD=&2
def _VERSION=&3

accept _PDH_NAME char def '&_PDH_NAME' prompt 'Type PDH user name [&_PDH_NAME]: '
accept _PDH_PWD char def '&_PDH_PWD' prompt 'Type PDH user password [&_PDH_PWD]: ' hide

--WHENEVER SQLERROR EXIT FAILURE
--WHENEVER OSERROR EXIT FAILURE

conn &_PDH_NAME/&_PDH_PWD

set serveroutput on

select 'Connected to ' || dbms_standard.database_name() || ' as ' || dbms_standard.login_user() || ' at ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss') "Connection" from dual;

set verify off
set define on

select to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss') "General install" from dual;
@@_install_.sql

select to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss') "Install complete at" from dual;

exit

