. /home/oracle/.db_env
cp ${DIR}/init/* $ORACLE_HOME/dbs/
sqlplus /nolog @${DIR}/startup_auxiliary.sql
rman @${DIR}/duplicate_db.rman log $RMNLOG
