def log_file = '&1';
connect / as sysdba
@@set_env.sql
prompt Log continue into &log_file
spool &log_file
set termout off
WHENEVER SQLERROR CONTINUE
alter pluggable database tstdb open read write force;
whenever sqlerror exit failure rollback
alter session set container=tstdb;
@$ORACLE_HOME/rdbms/admin/utluppkg.sql
exec dbms_preup.run_fixup_and_report('INVALID_SYS_TABLEDATA');
@$ORACLE_HOME/rdbms/admin/noncdb_to_pdb.sql
connect / as sysdba
@@set_env.sql
alter pluggable database tstdb close immediate;
spool off
set termount on
alter pluggable database tstdb open;
show pdbs;
alter session set container=tstdb;
exec dbms_stats.gather_system_stats();
exec sys.dbms_stats.gather_system_stats('START');
alter session disable parallel query;
select /*+ FULL(a) */ count(*) from gazfond_pn.people a;
exec sys.dbms_stats.gather_system_stats('STOP');
exit