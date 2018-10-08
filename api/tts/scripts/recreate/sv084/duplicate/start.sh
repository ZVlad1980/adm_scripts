TARGET=$1
RMNLOG="${DIR}/logs/rmn_"`date +%y%m%d`"_"`date +%H%M`".log"
SRC_HOST="oracle@10.1.1.108"
TTS_FILE="tts_ready_"`date +%y%m%d`

echo "Start create duplicate datebase"
echo "Target DB:${TARGET}"
. ${DIR}/copy_scp.sh "/ora1/buf/datapump/"${TTS_FILE} "${DIR}/logs"
if [ ! -f "${DIR}/logs/${TTS_FILE}" ] 
then
  echo "File ${TTS_FILE} not found."
  exit 1;
fi
echo "Copy files start at "`date`
. ${DIR}/copy_files.sh
echo "Recreate NODE ${TARGET} at"`date`
. ${DIR}/recreate_db.sh
echo "Convert start at "`date`
rman target / @"${DIR}/convert_${TARGET}.rman" LOG=$RMNLOG
echo "Convert complete at "`date`
sleep 180
echo "Import start at "`date`
. ${DIR}/import.sh
echo "Post import start at "`date`
. ${DIR}/post_import.sh
echo "TTS COMPELTE AT "`date`
exit
