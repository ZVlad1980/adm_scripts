TARGET=$1
SOURCE=$2
ACFS_PATH="${ORACLE_BASE}/oradata/dev"
TTS_FILE="${DIR}/../duplicate/logs/tts_ready_"`date --date="yesterday" +%y%m%d`

echo "Start create clone PDB ${SOURCE}"
echo "Target PDB: ${TARGET}"
if [ ! -f "${TTS_FILE}" ] 
then
  echo "File ${TTS_FILE} not found."
  exit 1;
fi
echo "Recreate PDB ${TARGET} at"`date`
. ${DIR}/recreate_db.sh
echo "Post import start at "`date`
. ${DIR}/post_import.sh
echo "TTS COMPELTE AT "`date`
exit