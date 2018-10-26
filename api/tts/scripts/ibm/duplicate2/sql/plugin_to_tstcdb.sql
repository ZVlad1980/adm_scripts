def xml_file = '&1';
def log_file = '&2';
connect / as sysdba
@@set_env.sql
startup
CREATE PLUGGABLE DATABASE tstdb using '&xml_file' nocopy tempfile reuse;
ALTER SESSION SET CONTAINER=tstdb;
prompt Log continue into &log_file
spool '&log_file'
set termout off
@$ORACLE_HOME/rdbms/admin/noncdb_to_pdb.sql
spool off
set termout on
exit