set serveroutput on
exec dbms_stats.gather_system_stats();
exec sys.dbms_stats.gather_system_stats('START');
alter session disable parallel query;
select /*+ FULL(a) */ count(*) from gazfond_pn.people a;
exec sys.dbms_stats.gather_system_stats('STOP');
exit;
