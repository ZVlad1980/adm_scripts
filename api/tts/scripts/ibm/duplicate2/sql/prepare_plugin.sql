def xml_file = '&1';
connect / as sysdba
@@set_env.sql
shut immediate;
startup mount;
alter database open read only;
exec DBMS_PDB.DESCRIBE(pdb_descr_file => '&xml_file');
shut immediate
exit
