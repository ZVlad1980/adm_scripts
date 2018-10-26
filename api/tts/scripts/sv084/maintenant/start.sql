set echo on
startup
alter pluggable database pdb_root open;
exec pdb_api.restore_open_mode;
exit