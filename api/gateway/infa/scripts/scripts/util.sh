declare __log_file=""
declare __error_msg=""

set_log_file(){
  __log_file=${1}
out "New LOG START"
}

out(){
  local msg="${1:-}"

  if [[ -n "${msg}" ]]; then
    if [[ -z ${__log_file} ]]; then
      echo -e "[$(date)]: ${msg}"
    else
      echo -e "[$(date)]: ${msg}" | tee -a "${__log_file}"
    fi
  fi
}

finalize() {
  local result=$?

  if [[ -n "${PAR_FILE:-}" ]]; then
    rm -fr "${PAR_FILE}"
  fi

  if [[ ! -z "${__error_msg:-}" || (${result} -ne 0) ]]
  then
    out "Fatal error: ${__error_msg:-'Unexpected error'}"
  fi
  trap - EXIT ERR
  exit ${result}
}

set_error() {
  __error_msg="${1:-}"
}

raise(){
  set_error "${1:-'Undefined error'}"
  exit 1
}
