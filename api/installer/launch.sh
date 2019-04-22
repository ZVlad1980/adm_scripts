#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

declare -r __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -r __dir_log="${__dir}/logs"
declare -r __dir_ora="${__dir}/oracle"
declare -r __dir_ora_scripts="${__dir_ora}/scripts"
declare -r __dir_repos="${__dir}/repos"
declare -r __log_file="${__dir_log}/install_$(date +%y%m%d)_$(date +%H%M)_${$}.log"
declare -r __curr_dir=$(pwd)
declare -r __only_scripts="${PDH_INST_ONLY_SCRIPTS-1}"

declare __result

mkdir -p "${__dir_log}"
mkdir -p "${__dir_repos}"

. "${__dir_ora}/env/ora.env"
. "${__dir}/util.sh"
. "${__dir}/oracle_api.sh"
. "${__dir}/installer.sh"
. "${__dir}/install_api.sh"


trap finalize INT TERM EXIT

out "Log file: ${__log_file}"
set_log_file "${__log_file}"

out "Launcher start, parameters: ${*-Without parameters}"

install "${@}"

exit 0