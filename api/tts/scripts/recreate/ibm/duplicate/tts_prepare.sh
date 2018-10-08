echo "TTS prepare start"
. /home/oracle/.cdb_env
sqlplus /nolog @"${DIR}/tts_install.sql"
sqlplus /nolog @"${DIR}/tts_prepare.sql"
rm -f /ora1/buf/datapump/expdat.dmp
rm -f /ora1/buf/datapump/export.log
echo "TTS export start"
expdp system/"17trhtnC.cntv"@tstdb full=y dumpfile=expdat.dmp directory=data_dump_dir transportable=always logfile=export.log > $EXPLOG
echo "TTS export complete"
rm -f /ora1/buf/datapump/tts_ready*
echo "TTS Ready" > /ora1/buf/datapump/tts_ready_`date +%y%m%d`
