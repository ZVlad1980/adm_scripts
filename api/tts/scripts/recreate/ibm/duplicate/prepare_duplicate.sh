. /home/oracle/.cdb_env
sqlplus /nolog @${DIR}/prepare_duplicate.sql
rm -fr /ora1/dat/tstdb/arc/*
rm -fr /ora1/dat/tstdb/ctl/*
rm -fr /ora1/dat/tstdb/redo/*
rm -fr /ora1/dat/tstdb/dbs/*
rm -f /ora1/12_1_0/dbs/spfiletstdb.ora
