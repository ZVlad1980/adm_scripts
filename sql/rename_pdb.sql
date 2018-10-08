alter pluggable database dev_node close immediate;
alter pluggable database dev_node open restricted;
alter session set container=dev_db;
alter pluggable database rename global_name to dev_db;
alter pluggable database close immediate;
alter pluggable database open;
