conn / as sysdba
@@set_env.sql
startup;
alter pluggable database pdb_root open;
connect pdb_root/pdb_root@pdb_root
exec pdb_api.restore_open_mode;
exit;
