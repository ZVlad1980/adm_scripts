sqlplus sys/"oSposC.c"@${TARGET} as sysdba @"${DIR}/post_import/disable_all_jobs.sql"
sqlplus sys/"oSposC.c"@${TARGET} as sysdba @"${DIR}/post_import/grant_on_sys.sql"
echo "Post import recreate clones, at "`date`
sqlplus pdb_root/pdb_root@pdb_root @"${DIR}/post_import/recreate_clones_${TARGET}.sql"
