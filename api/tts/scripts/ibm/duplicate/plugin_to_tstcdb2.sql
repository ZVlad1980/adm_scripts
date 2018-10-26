connect / as sysdba
alter session set container=tstdb;
@$ORACLE_HOME/rdbms/admin/utluppkg.sql
exec dbms_preup.run_fixup_and_report('INVALID_SYS_TABLEDATA');
@$ORACLE_HOME/rdbms/admin/noncdb_to_pdb.sql
connect / as sysdba
alter pluggable database tstdb close immediate;
alter pluggable database tstdb open;
show pdbs;
exec dbms_stats.gather_system_stats();
exec sys.dbms_stats.gather_system_stats('START');
alter session disable parallel query;
select /*+ FULL(a) */ count(*) from gazfond_pn.people a;
exec sys.dbms_stats.gather_system_stats('STOP');
exit
