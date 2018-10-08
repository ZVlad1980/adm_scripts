echo "Drop node ${TARGET}, at "`date`
sqlplus / as sysdba @"${DIR}/recreate_node/drop_node.sql" "${TARGET}"
echo "Stop PDB Daemon at "`date`
sqlplus /nolog @"${DIR}/recreate_node/stop_daemon.sql"
echo "Restart TSTCDB at "`date`
sqlplus / as sysdba @"${DIR}/recreate_node/restart_tstcdb.sql"
echo "Start PDB Daemon at "`date`
nohup sqlplus /nolog @"${DIR}/recreate_node/start_daemon.sql" &
echo "Create source node ${TARGET}, at "`date`
sqlplus / as sysdba @"${DIR}/recreate_node/create_${TARGET}.sql"
echo "Recreate complete at "`date`
