#!/usr/bin/sh

DIR=`dirname $0`
if [ `expr substr $DIR 1 1` = "." ]; then DIR=`pwd`; fi
if [ ! -f /ora1/sav/bkup/* ]
then
  echo "Backup not found. /ora1/sav/bkup/*"
  exit 0;
fi

mkdir -p ${DIR}/logs
RMNLOG="${DIR}/logs/rman_"`date +%y%m%d`"_"`date +%H%M`".log"
SQLLOG="${DIR}/logs/sql_"`date +%y%m%d`"_"`date +%H%M`".log"
CNVLOG="${DIR}/logs/conv_"`date +%y%m%d`"_"`date +%H%M`".log"
EXPLOG="${DIR}/logs/exp_"`date +%y%m%d`"_"`date +%H%M`".log"
echo "Prepare duplicate start at "`date` > $SQLLOG
. ${DIR}/prepare_duplicate.sh >> $SQLLOG
echo "Prepare complete at "`date` >> $SQLLOG
. ${DIR}/create_duplicate.sh >> $SQLLOG
echo "Create duplicate complete at "`date`  >> $SQLLOG
echo "Post duplicate start"
. ${DIR}/post_duplicate.sh >> $SQLLOG
echo "Post duplicate complete at "`date` >> $SQLLOG
echo "Plugin TSTDB to TSTCDB" >> $SQLLOG
. ${DIR}/plugin_to_tstcdb.sh >> $SQLLOG
echo "Plugin complete at "`date` >> $SQLLOG
echo "Prepare TTS start"
. ${DIR}/tts_prepare.sh >> $SQLLOG
echo "Prepare TTS complete at "`date` >> $SQLLOG
exit
