alter session set db_create_file_dest='/ora1/dat/releases'
create pluggable database zpdb_node admin user admin identified by passwd;
alter pluggable database zpdb_node open;
connect to zpdb_node as sysdba @create_test_users.sql;
