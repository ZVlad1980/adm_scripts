begin
  DBMS_STATS.PURGE_STATS(DBMS_STATS.PURGE_ALL);
  --DBMS_STATS.gather_schema_stats(
  --dbms_stats.drop_extended_stats('INF', 'CLIENTS', '(FIO1, FIO2, FIO3)');--'(FIO1, FIO2, FIO3)');
exception
  when others then
    dbms_output.put_line(sqlerrm);
    raise;
end;
/
DECLARE
  l_cg_name VARCHAR2(30);
BEGIN
  l_cg_name := DBMS_STATS.create_extended_stats(ownname   => 'INF',
                                                tabname   => 'CLIENTS',
                                                extension => '(TRIM(STATUS))');
  DBMS_OUTPUT.put_line('l_cg_name=' || l_cg_name);
END;
/
SELECT *--extension_name, extension
FROM   dba_stat_extensions ds
WHERE  table_name = 'CLIENTS'
and    ds.owner = 'INF';
