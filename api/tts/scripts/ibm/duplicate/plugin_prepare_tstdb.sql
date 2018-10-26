connect / as sysdba
shut immediate;
startup mount;
alter database open read only;
exec DBMS_PDB.DESCRIBE(pdb_descr_file => '/home/oracle/tstcdb/tstdb.xml');
shut immediate
exit
