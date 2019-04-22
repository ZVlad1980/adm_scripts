#! /usr/bin/env bash

if [ -z "${TWO_TASK}" ]; then
  echo "Fail: TWO_TASK is empty. Please defaine TWO_TASK and rerun"
  exit 1
fi

set -o errexit
set -o pipefail
set -o nounset
#set -o xtrace


declare -r __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -r __log_dir="${__dir}/log"
declare -r __log_file="${__log_dir}/${TWO_TASK}_ins_"`date +%y%m%d`"_"`date +%H%M`".log"

mkdir -p "${__log_dir}"

declare -r l_version="$(cat ${__dir}/version_info)"
echo "It will install version: ${l_version}"

sqlplus /nolog @"${__dir}/_install.sql" prod_pdh PROD_PDH "${l_version}" | tee -a "${__log_file}"

