#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io
#   https://kvz.io/blog/2013/11/21/bash-best-practices/
set -o errexit
set -o pipefail
set -o nounset
#set -o xtrace

if [ -z "${ORACLE_HOME}" ]
then
  . /home/oracle/.profile
fi

declare -r __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sqlplus / as sysdba @"${__dir}/shut_tstcdb.sql"
lsnrctl stop
sudo shutdown -r

exit
