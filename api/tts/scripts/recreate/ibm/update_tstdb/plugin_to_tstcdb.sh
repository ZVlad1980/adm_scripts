rm -f /home/oracle/tstcdb/tstdb.xml
. /home/oracle/.db_env
sqlplus /nolog @"${DIR}/plugin_prepare_tstdb.sql"
. /home/oracle/.cdb_env
echo "Apply plugin_to_tstcdb.sql 1 RUN"
sqlplus /nolog @"${DIR}/plugin_to_tstcdb.sql" > $CNVLOG
echo "Apply plugin_to_tstcdb.sql 2 RUN"
sqlplus /nolog @"${DIR}/plugin_to_tstcdb2.sql" >> $CNVLOG
