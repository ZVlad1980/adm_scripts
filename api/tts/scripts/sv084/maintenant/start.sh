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
declare -r __root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app  

. /home/oracle/.cdb_env
echo Start acfsload
sudo /u01/app/oracle/product/12.2.0/grid/bin/acfsload start
echo Start Oracle listener
. /home/oracle/.grid_env
$ORACLE_HOME/bin/lsnrctl start
#иногда автозапуск не проходит, поэтому на всякий случай
echo Start ASM instance
$ORACLE_HOME/bin/srvctl start asm 
sleep 20

echo Prepare ACFS diskgroups
$ORACLE_HOME/bin/asmcmd umount -a 
$ORACLE_HOME/bin/asmcmd mount -a
$ORACLE_HOME/bin/asmcmd volenable --all

echo Mount ACFS disks
sudo /bin/mount -t acfs /dev/asm/vol_dev-420 /u01/app/oracle/oradata/dev
sudo /bin/mount -t acfs /dev/asm/vol_weekly-82 /u01/app/oracle/oradata/weekly

echo Start Oracle DB instance
. /home/oracle/.cdb_env
sqlplus / as sysdba @"${__dir}/start.sql"

echo Start PDB_DAEMON
source "${__root}/pdb_daemon/start.sh"
echo Complete

exit
