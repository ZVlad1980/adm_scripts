. /home/oracle/.cdb_env
sqlplus /nolog @"${DIR}/tts_prepare.sql"
echo "TTS export start at "`date`
DUMPFILE="export_tts_"`date +%y%m%d`".dmp"
LOGFILE="export_tts_"`date +%y%m%d`".log"
expdp system/passwd@tstdb full=y dumpfile=${DUMPFILE} directory=data_dump_dir transportable=always logfile=${LOGFILE}
echo "TTS export complete at "`date`