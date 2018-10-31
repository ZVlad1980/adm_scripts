#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io
#   https://kvz.io/blog/2013/11/21/bash-best-practices/

wait_clean_snaps(){

  local acfs_path="${ORACLE_BASE}/oradata/${1}"
  local del_lines=1

  while [ $del_lines -gt 0 ]
  do
    set +e
    del_lines=`acfsutil snap info "${acfs_path}" | grep -c "delete in progress"`
    set -e
      
    if [ "${del_lines}" -eq 0 ]
    then
      break;
    fi
    (( del_lines-=1 ))
    out "Delete processing ${del_lines}. Sleep 60 sec"
    sleep 20
  done
}

set -o errexit
set -o pipefail
set -o nounset
#set -o xtrace

if [ -z "${ORACLE_HOME}" ]
then
  . /home/oracle/.bash_profile
fi

declare -r __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo Stop Oracle instance
. /home/oracle/.cdb_env
echo shut_tstcdb.sql
#sqlplus /nolog @"${__dir}/shut_tstcdb.sql"
echo wait dev
wait_clean_snaps dev
echo wait weekly
wait_clean_snaps weekly
echo Stop complete

echo Umount ACFS disks
sudo umount /u01/app/oracle/oradata/dev
sudo umount /u01/app/oracle/oradata/weekly
echo Umount ACFS diskgroups
. /home/oracle/.grid_env
$ORACLE_HOME/bin/asmcmd voldisable --all
$ORACLE_HOME/bin/asmcmd umount -a
echo Stop Oracle listener
$ORACLE_HOME/bin/lsnrctl stop
echo Stop ASM instance
$ORACLE_HOME/bin/srvctl stop asm
echo REBOOT
sudo reboot 0

exit
