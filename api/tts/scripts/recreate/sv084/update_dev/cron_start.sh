#!/bin/bash
if [ -z "$ORACLE_BASE" ]
then
. /home/oracle/.bash_profile
echo "Run .bash_profile"
fi

DIR=`dirname $0`
if [ `expr substr $DIR 1 1` = "." ]; then DIR=`pwd`; fi
mkdir -p ${DIR}/logs
SCRLOG="${DIR}/logs/scr_"`date +%y%m%d`"_"`date +%H%M`".log"
. ${DIR}/start.sh "DEV_NODE" "WEEKLY_NODE" > $SCRLOG
