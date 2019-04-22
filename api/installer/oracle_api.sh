request_ora(){
  local l_action="${1}"
  local l_extension="${2}"
  local l_add_params="${3:-}"
  local f_result="${__dir}/__result.dat"
  
  rm -fr "${f_result}"
  out "Request ORA: ${l_action} ${l_extension} ${l_add_params}"
  sqlplus -s /nolog @"${__dir_ora}/scripts/request.sql" "${__dir_ora}/env/${TWO_TASK}.env" "${f_result}" "${l_action}" "${l_extension}" "${l_add_params}"
  
  if [ -f "${f_result}" ]; then
    __result=$(cat "${f_result}" | xargs)
    #rm -fr "${f_result}"
  else
    raise "Request Ora: result file not found: ${f_result}" 
  fi
  rm -fr "${f_result}"
}