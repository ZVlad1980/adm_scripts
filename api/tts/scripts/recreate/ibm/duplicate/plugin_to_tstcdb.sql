connect / as sysdba
startup
CREATE PLUGGABLE DATABASE tstdb using '/home/oracle/tstcdb/tstdb.xml' nocopy tempfile reuse;
ALTER SESSION SET CONTAINER=tstdb;
@$ORACLE_HOME/rdbms/admin/noncdb_to_pdb.sql
exit
