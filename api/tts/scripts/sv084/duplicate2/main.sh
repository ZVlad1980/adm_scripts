#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io
#   https://kvz.io/blog/2013/11/21/bash-best-practices/
if [ -z "${ORACLE_HOME}" ]
then
  . /home/oracle/.bash_profile
fi

set -o errexit
set -o pipefail
set -o nounset
#set -o xtrace


declare -r __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -r __file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
declare -r __base="$(basename ${__file} .sh)"
declare -r __root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app  

#################################################
## Include
#################################################
. "${__dir}/util.sh"
. "${__dir}/duplicate.sh"

trap finalize INT TERM EXIT

set_lock

mkdir -p "${__dir}/logs"
declare -r __TARGETDB="${1:-WEEKLY_NODE}"
declare -r __LOGFILE="${__dir}/logs/_update_"`date +%y%m%d`"_"`date +%H%M`".log"

out "Starting update DB ${__TARGETDB}, log into ${__LOGFILE}"
duplicate "${__TARGETDB}" &>> "${__LOGFILE}"

exit