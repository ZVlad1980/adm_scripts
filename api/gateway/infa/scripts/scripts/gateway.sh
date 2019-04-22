parse_parameters(){
  local JSON=""
  local is_module=0
  local is_action=0
  local l_log_dir

  while (( "$#" )); do
    key="$1"
    case $key in
      -OM)
        add_param "PDH_MODULE" "${2}"
        is_module=1
        shift 2
        ;;
      -OA)
        add_param "PDH_ACTION" "${2}"
        is_action=1
        shift 2
        ;;
      -OP)
        add_json "${2}"
        shift 2
        ;;
      --LOG_DIR)
        l_log_dir="${2}"
        shift 2
        ;;
      *)
        break
        ;;
    esac
  done
  
  if [[ ${is_module} -eq 0 ]]; then
    raise "PDH GATEWAY MODULE NAME is missed"
  elif [[ ${is_action} -eq 0 ]]; then
    raise "PDH GATEWAY ACTION is missed"
  fi

  add_param "PDH_INPUTS" "{${JSON}}"

  if [ -n "${l_log_dir-}" ]; then
    FOLDER_NAME="PDH_$(echo ${l_log_dir} | cut -d / -f 5)_EXCEPTION"
  else
    FOLDER_NAME=$1
    shift
  fi

  WORKFLOW=$1
echo $FOLDER_NAME
echo $WORKFLOW
}


add_json(){
  local par_name=$(echo ${1} | awk -F= '{print $1}')
  local par_value=$(echo ${1} | awk -F= '{print $2}')
  if [[ -n $JSON ]]; then
    JSON+=","
  fi
  JSON+='"'${par_name}'":"'${par_value}'"'
}


add_param(){
  PARAMS+=$(echo '$$'"${1}=${2}\n")
}

create_par_file(){
  local FOLDER_NAME="${1}"
  local WORKFLOW="${2}"
  local INFA_PARAM_FILE="${3}"
  local PARAMS="${PARAMS}"
  local BASE_PARAM_FILE="${__dir_par}/PDH_ParamFile_GATEWAY.par"
  
  out "Create directore ${__dir_par}"
  mkdir -p "${__dir_par}"
  out "Copy source parameters file ${BASE_PARAM_FILE} to ${INFA_PARAM_FILE}"
  cp "${BASE_PARAM_FILE}" "${INFA_PARAM_FILE}"
  
  echo "" >> "${INFA_PARAM_FILE}"
  echo "[${FOLDER_NAME}.WF:${WORKFLOW}]" >> "${INFA_PARAM_FILE}"
  echo "" >> "${INFA_PARAM_FILE}"
  echo -e "${PARAMS}" >> "${INFA_PARAM_FILE}"

}
