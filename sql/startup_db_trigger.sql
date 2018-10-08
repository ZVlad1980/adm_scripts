CREATE or REPLACE trigger OPEN_ALL_PLUGGABLES 
   after startup 
   on  database 
BEGIN 
   execute immediate 'alter pluggable database all open'; 
END open_all_pdbs;
