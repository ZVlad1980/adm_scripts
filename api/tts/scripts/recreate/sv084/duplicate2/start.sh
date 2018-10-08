TARGET=$1
RMNLOG="${DIR}/logs/rmn_"`date +%y%m%d`"_"`date +%H%M`".log"
SRC_HOST="oracle@10.1.1.108"
TTS_FILE="tts_ready_"`date +%y%m%d`

echo "Start create duplicate datebase"
echo "Target DB:${TARGET}"
echo "Drop node ${TARGET}, at "`date`
sqlplus / as sysdba @"${DIR}/recreate_node/drop_node.sql" "${TARGET}"
echo "Import start at "`date`
. ${DIR}/import.sh
echo "Post import start at "`date`
. ${DIR}/post_import.sh
echo "TTS COMPELTE AT "`date`
exit
