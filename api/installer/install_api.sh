#!/bin/usr/env bash

declare -r C_OBJ_SHOW_ERROR="Packages PackageBodies Types TypeBodies"

install_extension(){
  local l_extension_dir="${1}"
  local l_filters="${2}"
  local l_only_scripts="${3}"
  local l_install="${l_extension_dir}/_install"
  local l_install_tmp="${l_extension_dir}/_install_${TWO_TASK}.sql"
  #local l_script="${l_extension_dir}/_install.sql"
  
  out "--------------"
  out "Install start"

  if [[ ! -f "${l_install}" ]]; then
    out "Install fail. The description file ${l_install} not found"
    exit 1
  fi

  if [[ ! -f "${l_filters}" ]]; then
    l_filter=""
    out "Filters were not found (${l_filters}), it will install all scripts"
  fi

  if [[ -f "${l_install_tmp}" ]]; then
    rm -f "${l_install_tmp}"
  fi
  build_tmp "${l_extension_dir}" "${l_install}" "${l_install_tmp}" "${l_filters}" 
  check_tmp "${l_extension_dir}" "${l_install_tmp}" "${l_filters}"

  if [[ "${l_only_scripts}" == "N" ]]; then
    run_script "${l_extension_dir}" "${l_install_tmp}"
    rm -fr "${l_install_tmp}"
  else
    out "IT'S SET MODE ONLY SCRIPTS, RESULT: ${l_install_tmp}"
  fi
}

exists_row(){
  local l_file="${1}"
  local l_str="${2}"
  local l_result

  if cat "${l_file}" | grep "${l_str}" | wc -l 2>/dev/null; then
    l_result=0
  else
    l_result=1
  fi

  return ${l_result}

}

build_tmp(){
  local l_extension_dir="${1}"
  local l_install="${2}"
  local l_install_tmp="${3}"
  local l_filters="${4}"

  local l_indent=0
  local l_indent_new=0
  local l_decrease
  local l_path=''
  local l_path_piece=''
  local l_fs_obj=''
  local l_line_num=0
  local l_object_type
  local l_IFS="${IFS}"

  cp "${__dir_ora_scripts}/env.sql" "${l_extension_dir}/env.sql"
  
  IFS=$'\n'
  
  function push_row_(){
    echo "${1}" >> "${l_install_tmp}"
  }

  function parse_command_(){
    local l_in_cmd="${1}"
    local l_cmd=$(expr match "${l_in_cmd}" '^\(.[a-z\s]*\)')

    push_row_ "${l_in_cmd}"


    if [[ "${l_cmd}" == "conn" ]]; then
      push_row_ "@@env.sql"
    fi
  }

  function parse_path_(){
    l_fs_obj="${l_extension_dir}/${l_path}${l_delim}${l_path_piece}"
    #out "l_fs_obj = ${l_fs_obj}"

    if [[ -f "${l_fs_obj}" ]]; then
      if exists_row "${l_filters}" "${l_fs_obj}"; then
        push_row_ "prompt Install ${l_path_piece}"
        push_row_ "@${l_fs_obj}"
#        out "indent: ${l_indent}, object types: ${l_object_type}"
        if [[ $l_indent -gt 0 && "${C_OBJ_SHOW_ERROR}" =~ "${l_object_type}" ]]; then
          push_row_ "show errors"
        fi
      fi
    elif [[ -d "${l_fs_obj}" ]]; then
      l_path="${l_path}${l_delim}${l_path_piece}"
    else
      raise "FS object ${l_fs_obj} not found or file ${l_install} has incorrect indent in line ${l_line_num}"
    fi
  }

  push_row_ "@@env.sql"
  push_row_ "@${__dir_ora}/env/${TWO_TASK}.env"
  
  
  for line in $(cat "${l_install}"); do
    l_line_num=$(( l_line_num+1 ))
#out "line num: ${l_line_num} ${line}"
    l_path_piece=$(echo "${line}" | cut -d'#' -f 1)
#out "l_path_piece = ${l_path_piece}"
    l_indent_new=$( expr match "${l_path_piece}" "^[[:space:]]*" ) && true
#out "l_indent_new = ${l_indent_new}"
    l_path_piece=${l_path_piece:l_indent_new}
    l_path_piece=${l_path_piece/ /}
#out "l_path_piece = '${l_path_piece}'"
    if (( $l_indent_new == 0 )); then
      if (( $l_indent > 0 )); then
        push_row_ "prompt ======================"
        push_row_ "prompt Complete ${l_object_type}"
        push_row_ "prompt ======================"
      fi
      l_path=''
      l_indent=0
      l_delim=''
    else
      l_decrease=$(( l_indent_new/2 - l_indent/2 ))
      #out "Decrease: l_decrease = ${l_indent_new}/2 - ${l_indent}"
      l_delim='/'
      for (( i=l_decrease; i<0; i++ )); do
        l_path="${l_path%/*}"
        #out "Decrease path: ${l_path}"
        #l_indent=$(( l_indent + 1 ))
      done
      l_indent=${l_indent_new}
    fi
    
    if [[ "${l_path_piece:0:1}" == "@" ]]; then
      parse_command_ "${l_path_piece:1}"
    else
      if (( l_indent == 0 )); then
        l_object_type=${l_path_piece}
        push_row_ "prompt ======================"
        push_row_ "prompt Install ${l_object_type}"
        push_row_ "prompt ======================"
      fi
      parse_path_
    fi
    
    #out "--------------------------------"
  done
  IFS="${l_IFS}"
  push_row_ "prompt ======================"
  push_row_ "prompt ======================"
  push_row_ "prompt Install complete succesful"
  push_row_ "prompt ======================"
  push_row_ "exit"
}

check_tmp(){
  local l_extension_dir="${1}"
  local l_install_tmp="${2}"
  local l_filters="${3}"
  local l_result=0

  out "Checking content install scripts: ${l_install_tmp}"

  for line in $(cat "${l_filters}"); do
    if ! exists_row "${l_install_tmp}" "${line}"; then
      out "The file script is not found into install script:"
      out "${line}"
      l_result=1
    fi
  done

  if (( l_result == 1 )); then
    raise "Install script isn't contain all files"
  fi

  out "Checking TMP file is OK"
}

run_script(){
  l_extension_dir="${1}"
  l_install_tmp="${2}"
  sqlplus /nolog @"${l_install_tmp}" | tee -a "${__lcl_log_file}"
}