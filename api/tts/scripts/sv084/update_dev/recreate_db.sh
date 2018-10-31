echo "Drop node ${TARGET}, at "`date`
sqlplus / as sysdba @"${DIR}/recreate_node/drop_node.sql" "${TARGET}"
echo "Stop PDB Daemon at "`date`
sqlplus /nolog @"${DIR}/recreate_node/stop_daemon.sql"
echo "Stop TSTCDB at "`date`
sqlplus / as sysdba @"${DIR}/recreate_node/stop_tstcdb.sql"
echo "Wait deleting snap info"
. ${DIR}/wait_deleting.sh
echo "Start TSTCDB at "`date`
sqlplus / as sysdba @"${DIR}/recreate_node/start_tstcdb.sql"
echo "Start PDB Daemon at "`date`
nohup sqlplus /nolog @"${DIR}/recreate_node/start_daemon.sql" &
echo "Wait reopen PDBS"
sleep 120
echo "Ok"
echo "Create PDB ${TARGET} clone ${SOURCE}, at "`date`
sqlplus / as sysdba @"${DIR}/recreate_node/create_${TARGET}.sql"
echo "Recreate complete at "`date`
