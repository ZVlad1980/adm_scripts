#!/usr/bin/env bash

declare -r __LOCKFILE="${__dir}/lock.lck"
declare -r __TWO_TASK="${TWO_TASK:-}"
declare __error_msg=""

set_lock(){
  
  if ! ( set -o noclobber; echo "$$" > "${__LOCKFILE}") 2> /dev/null; 
  then
    set_error "Failed to acquire lockfile: ${__LOCKFILE}"
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
    echo "($(date)): ${msg}"
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
  echo "export ORACLE_SID=${ORACLE_SID}"
}

scp_copy(){
  local src="${1:-}"
  local trg="${2:-}"
  set_error "error scp -c arcfour ${src} ${trg}"
  scp -c arcfour "${src}" "${trg}" 
  set_error
  #2>> "${__dir}/logs/scp.log"
}

wait_clean_snaps(){

  local acfs_path="${ORACLE_BASE}/oradata/${1}"
  local del_lines=1

  while [ $del_lines -gt 0 ]
  do
    set +e
    del_lines=`acfsutil snap info "${acfs_path}" | grep -c "delete in progress"`
    set -e
      
    if [ "${del_lines}" -eq 0 ]
    then
      break;
    fi
    (( del_lines-=1 ))
    out "Delete processing ${del_lines}. Sleep 60 sec"
    sleep 20
  done
}