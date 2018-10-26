#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io
#   https://kvz.io/blog/2013/11/21/bash-best-practices/
set -o errexit
set -o pipefail
set -o nounset
#set -o xtrace

if [ -z "${ORACLE_HOME}" ]
then
  . /home/oracle/.bash_profile
fi

declare -r __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo Stop Oracle isntance
. /home/oracle/.cdb_env
sqlplus / as sysdba @"${__dir}/shut_tstcdb.sql"
. ./wait_deleting.sh dev
. ./wait_deleting.sh weekly

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
