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

if [ -z __dir ]
then
  __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

. /home/oracle/.cdb_env
nohup sqlplus /nolog @"${__dir}/sql/start_daemon.sql" & 

exit