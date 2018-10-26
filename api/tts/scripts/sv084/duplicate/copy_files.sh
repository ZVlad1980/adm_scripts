rm -f /u01/app/oracle/buf/datapump/expdat.dmp
rm -f /u01/app/oracle/buf/datapump/import.log
rm -f /u01/app/oracle/backup/aix_files/*
. ${DIR}/copy_scp.sh /ora1/dat/tstdb/dbs/arh* /u01/app/oracle/backup/aix_files/      
. ${DIR}/copy_scp.sh /ora1/dat/tstdb/dbs/ctx* /u01/app/oracle/backup/aix_files/      
. ${DIR}/copy_scp.sh /ora1/dat/tstdb/dbs/dwh* /u01/app/oracle/backup/aix_files/      
. ${DIR}/copy_scp.sh /ora1/dat/tstdb/dbs/inf* /u01/app/oracle/backup/aix_files/      
. ${DIR}/copy_scp.sh /ora1/dat/tstdb/dbs/mdm* /u01/app/oracle/backup/aix_files/      
. ${DIR}/copy_scp.sh /ora1/dat/tstdb/dbs/ops* /u01/app/oracle/backup/aix_files/      
. ${DIR}/copy_scp.sh /ora1/dat/tstdb/dbs/web* /u01/app/oracle/backup/aix_files/      
. ${DIR}/copy_scp.sh /ora1/dat/tstdb/dbs/f* /u01/app/oracle/backup/aix_files/        
. ${DIR}/copy_scp.sh /ora1/dat/tstdb/dbs/g* /u01/app/oracle/backup/aix_files/        
. ${DIR}/copy_scp.sh /ora1/dat/tstdb/dbs/smppdat01* /u01/app/oracle/backup/aix_files/
. ${DIR}/copy_scp.sh /ora1/dat/tstdb/dbs/usr* /u01/app/oracle/backup/aix_files/      
. ${DIR}/copy_scp.sh /ora1/dat/tstdb/dbs/etl* /u01/app/oracle/backup/aix_files/      
. ${DIR}/copy_scp.sh /ora1/buf/datapump/tts/${EXPDAT_FILE} /u01/app/oracle/buf/datapump/export.dmp