def xml_file = '&1';
connect / as sysdba
@@set_env.sql
startup
CREATE PLUGGABLE DATABASE tstdb using '&xml_file' nocopy tempfile reuse;
ALTER SESSION SET CONTAINER=tstdb;
@$ORACLE_HOME/rdbms/admin/noncdb_to_pdb.sql
exit success