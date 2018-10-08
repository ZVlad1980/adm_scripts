echo "TTS prepare start"
. /home/oracle/.cdb_env
sqlplus /nolog @"${DIR}/tts_install.sql"
sqlplus /nolog @"${DIR}/tts_prepare.sql"
echo "TTS Ready" > /ora1/buf/datapump/tts_ready_`date +%y%m%d`
