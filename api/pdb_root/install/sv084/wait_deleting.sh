#! /usr/bin/bash
ACFS_PATH="${ORACLE_BASE}/oradata/"$1
DEL_LINES=1

while [ $DEL_LINES -gt 0 ]
do
DEL_LINES=`acfsutil snap info ${ACFS_PATH} | grep "delete in progress" | wc -l`
if [ $DEL_LINES -eq 0 ]
then
break;
fi
let "DEL_LINES-=1"
echo "Delete processing ${DEL_LINES}. Sleep 20 sec at "`date`
sleep 20
done
