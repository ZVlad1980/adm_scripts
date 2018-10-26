connect c##pdbroot/c##pdbroot@tstcdb as sysdba;
@@set_env.sql
exec pdb_daemon_api.stop_daemon;
exit
