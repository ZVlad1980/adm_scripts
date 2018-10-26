conn system
create or replace directory ext_tables_dir as '/home/oracle/external_tables';
grant read on directory ext_tables_dir to scott;
grant write on directory ext_tables_dir to scott;
