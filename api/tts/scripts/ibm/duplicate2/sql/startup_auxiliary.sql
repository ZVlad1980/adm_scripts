def ini_file = '&1';
connect / as sysdba
@@set_env.sql
prompt &ini_file
startup nomount pfile='&ini_file'
exit success