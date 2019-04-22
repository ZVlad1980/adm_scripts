SET FEEDBACK OFF
set echo off

def env='&1'
def result='&2'
def action='&3'
def extension='&4'
def add_params='&5'

@&env

conn &_pdh_name/&_pdh_pwd

set serveroutput on
SET FEEDBACK OFF
set echo off

spool &result

begin dbms_output.put_line('0.0.0'); end;
/
spool off

exit
