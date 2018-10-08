. /home/oracle/.db_env
sqlplus /nolog @${DIR}/post_duplicate.sql
sqlplus / as sysdba @${DIR}/disable_all_jobs.sql
