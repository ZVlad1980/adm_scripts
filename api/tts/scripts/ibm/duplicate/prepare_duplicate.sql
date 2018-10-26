connect / as sysdba
show pdbs
alter pluggable database tstdb close immediate;
drop pluggable database tstdb;
show pdbs
shut immediate
exit
