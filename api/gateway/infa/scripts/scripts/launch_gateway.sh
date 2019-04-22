#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

declare -r __env_list="PROD QA UAT DEV PERF PPD SIT"
declare -r __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -r __dir_log="/informatica/infa_home/PDH/logs"

declare __dir_par="/informatica/infa_home/PDH"
declare LOG_FILE="${__dir_log}/ALL_launch_gateway.log"


if [ -z "${SERVICE_NAME:-}" ]
then
  . ${__dir}/PDH.env
fi

. "${__dir}/util.sh"
. "${__dir}/gateway.sh"

trap finalize INT TERM EXIT

set_log_file "${LOG_FILE}"
out "Launcher start: ${*}"

declare FOLDER_NAME=""
declare WORKFLOW=""
declare PARAMS=""
declare PAR_FILE=""

out "Parse parameters"
parse_parameters "${@}"
out "Parse parameters complete"

if [[ -z ${FOLDER_NAME} ]]; then
  raise "FOLDER_NAME is missed"
elif [[ -z ${WORKFLOW} ]]; then
  raise "WORKFLOW is missed"
fi

declare __env=$(echo $FOLDER_NAME | cut -d'_' -f2)

if [[ "${__env_list}" =~ (^|[[:space:]])"${__env}"($|[[:space:]]) ]] ; then 
  out "ENV: ${__env}"
else
  raise "Unknown environment: ${__env}"
fi


if [[ ${__env} == "DEV" ]]; then
  __dir_par="${__dir_par}/parameter"
else
  __dir_par="${__dir_par}/${__env}/parameter"
fi

mkdir -p "${__dir_par}"
mkdir -p "${__dir_log}"

declare PAR_FILE="${__dir_par}/${WORKFLOW}_$$_$(date +%y%m%d)_$(date +%H%M%S).par"
LOG_FILE="${__dir_log}/${__env}_launch_gateway.log"

out "PAR_FILE: ${PAR_FILE}"
out "LOG_FILE: ${LOG_FILE}"

set_log_file "${LOG_FILE}"

out "[$(date +%Y-%m-%d_%H:%M:%S)]: $0 invoked with arguments: $*"
out "Parse arguments:" 
out "FOLDER_NAME = ${FOLDER_NAME}" 
out "WORKFLOW = ${WORKFLOW}" 
out "Parameters: "  
out "${PARAMS}"

out "Create parameters file"
create_par_file "${FOLDER_NAME}" "${WORKFLOW}" "${PAR_FILE}" "${PARAMS}" 
out "Parameters file is created"

RC_OUTPUT=99

set_error "Start workflow fail"
out "Start workflow"
pmcmd startworkflow -sv ${SERVICE_NAME} -d ${DOMAIN_NAME} -u ${USER_NAME} -p ${PASSWORD} -f ${FOLDER_NAME} -paramfile ${PAR_FILE} -wait ${WORKFLOW} | tee -a "${LOG_FILE}"
set_error ""

RC_OUTPUT=${PIPESTATUS[0]}

out "Workflow complete. Return STATUS=${RC_OUTPUT}" 

exit $RC_OUTPUT 
