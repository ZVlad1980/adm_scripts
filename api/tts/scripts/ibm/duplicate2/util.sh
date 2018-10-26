#!/usr/bin/env bash

declare -r __LOCKFILE="lock.lck"
declare -r __TWO_TASK="${TWO_TASK:-}"
declare __error_msg=""

set_lock(){
  
  if ! ( set -o noclobber; echo "$$" > "$__LOCKFILE") 2> /dev/null; 
  then
    set_error "Failed to acquire lockfile"
    exit 1
  fi
}

unlock(){
  rm -f "$__LOCKFILE"
}

show_var() {
  local v_name=$1
  echo "${v_name}: ${!v_name}"
}

set_error() {
  __error_msg="${1:-}"
}

raise(){
  set_error "${1:-'Undefined error'}"
  exit 1
}

out(){
  local msg="${1:-}"
  if ! [ -z "${msg}" ]
  then
    echo "($(date)): ${msg} "
  fi
}

finalize() {
  local result=$?
  
  unlock
  
  TWO_TASK=__TWO_TASK

  if [[ ! -z "${__error_msg}" || (${result} -ne 0) ]]
  then
    out "Fatal error: ${__error_msg:-'Unexpected error'}"
  fi
  trap - EXIT ERR
  exit ${result}
}

set_ora(){
  export ORACLE_SID="${1}"
  out "export ORACLE_SID=${ORACLE_SID}"
}