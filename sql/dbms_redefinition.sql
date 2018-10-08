--https://oracle-base.com/articles/misc/partitioning-an-existing-table#create_partitioned_interim_table
-- НАДО ДОБАВИТЬ ресинхронизацию, чтобы избежать переноса констрейнов
begin
  DBMS_REDEFINITION.can_redef_table('GAZFOND_PN', 'ASSIGNMENTS');
end;
ALTER SESSION FORCE PARALLEL DML PARALLEL 8;
ALTER SESSION FORCE PARALLEL QUERY PARALLEL 8;
begin
  DBMS_REDEFINITION.start_redef_table(
    uname      => 'GAZFOND_PN',        
    orig_table => 'ASSIGNMENTS',
    int_table  => 'ASSIGNMENTS2');
end;
/

/
BEGIN
  dbms_redefinition.finish_redef_table(
    uname      => 'GAZFOND_PN',        
    orig_table => 'ASSIGNMENTS',
    int_table  => 'ASSIGNMENTS2');
END;
/
