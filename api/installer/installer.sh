install(){
  declare -r c_env_list="PROD QA UAT DEV PERF PPD SIT"
  
  local l_repo="git@github.com:wiley/pdh.git"
  local l_repo_dir
  local l_repo_dir_auto="N"
  local l_checkout
  local l_extension
  local l_extension_dir
  local l_targets
  local l_only_scripts
  local l_sha
  local a_targets
  local l_version

  parse_parameters "${@}"

  if [[ -z "${l_repo_dir:-}" ]]; then
    l_repo_dir="${__dir_repos}/${l_extension}_$(date +%y%m%d)_$(date +%H%M)_${$}"
    l_repo_dir_auto="Y"
    out "Repo dir not define and will be create automatic"
    out "${l_repo_dir}"
  fi

  clone_repo "${l_repo}" "${l_repo_dir}" "${l_checkout}"
  
  l_sha="$(git --git-dir=${l_repo_dir}/.git rev-parse HEAD)"
  out "SHA: ${l_sha}"
  
  l_extension_dir="${l_repo_dir}/plsql"
  if [[ -d "${l_extension_dir}/extensions/${l_extension}" ]]; then
    l_extension_dir="${l_extension_dir}/extensions/${l_extension}"
  elif [[ -d "${l_extension_dir}/datafix/${l_extension}" ]]; then
    l_extension_dir="${l_extension_dir}/datafix/${l_extension}"
  else
    raise "Extension ${l_extension} was not found into: ${l_extension_dir}"
  fi

  out "Extension dir: ${l_extension_dir}"

  if [[ -f "${l_extension_dir}/version_info" ]]; then
    l_version=$(cat "${l_extension_dir}/version_info" | xargs)
    out "Repo version: ${l_version}"
  else
    l_version='99.99.99'
  fi

  a_targets=($(echo "${l_targets}" | tr ',' '\n'))
  for db in ${a_targets[@]}; do
    out "Install of extension to ${db} is start"
    install_db "${db}" "${l_version}" "${l_extension_dir}" "${l_extension}" "${l_only_scripts}" "${l_sha}" "${l_repo_dir}"
    out "Install of extension to ${db} completed"
  done
  
  if [[ "${l_repo_dir_auto}" == "Y" ]]; then
    rm -fr "${l_repo_dir}"
    out "Repos dir was autocreated so it was removed: ${l_repo_dir}"  
  fi
  exit 0
}

check_dependences(){
  local l_dependences="${1}/_dependences"
  local l_extension
  local l_version_req
  local l_version_db
  local l_result=0
  
  if [[ -f "${l_dependences}" ]]; then
    out "Check dependencies"
    for req in $(cat "${l_dependences}"); do
      if [[ "${req:0:1}" == "#" ]]; then continue; fi
      l_extension=$(echo "${req}" | cut -d"#" -f 1)
      l_version_req=$(echo "${req}" | cut -d"#" -f 2)
      
      request_ora "GET_VERSION" "${l_extension}"
      l_version_db="${__result}"
      
      if compare_version "${l_version_db}" "${l_version_req}"; then
        l_result=1
        out "Extension ${l_extension} must has version ${l_version_req}, current version: ${l_version_db}"
      fi
    done
  else
    out "File ${l_dependences} not found. Checking dependencies was skipped."
  fi
  return ${l_result}
}

create_filters(){
  local l_repo_dir="${1}"
  local l_extension_dir="${2}"
  local l_sha="${3}"
  local l_sha_db="${4}"
  local l_filters="${5}"
  local l_relative_path="${l_extension_dir:(${#l_repo_dir}+1)}"
  
  rm -f "${l_filters}"
  
  if [[ -z "${l_sha_db}" ]]; then
    out "Create filters: full filters only, install all scripts"
    find "${l_extension_dir}" -mindepth 2 -type f > "${l_filters}"
  else
    out "Read changes: git --git-dir=${l_repo_dir}/.git diff --name-only ${l_sha_db}... -- ${l_relative_path}"
    for f in $(git --git-dir="${l_repo_dir}/.git" diff --name-only --no-renames --diff-filter=ACM "${l_sha_db}..." -- "${l_relative_path}"); do
      #out $f
      if [[ "${f%/*}" == "${l_relative_path}" ]]; then
        out "Skip ${f}"
      else
        echo "${l_repo_dir}/${f}" >> "${l_filters}"
      fi
    done
  fi

  out "Create filters: complete"
  
}

check_version(){
  local l_client_version
  local l_server_version
  l_client_version="$(cat ${__dir}/version_info)"
  request_ora "GET_VERSION" "PDH_INSTALL"
  l_server_version="${__result}"
  if compare_version "${l_client_version}" "${l_server_version}"; then
    raise "PDH_INSTALL refused, client version (${l_client_version}) not compataible server version (${l_server_version})"
  fi
}

install_db(){      
  local l_target_db="${1}"
  local l_version_repo="${2}"
  local l_extension_dir="${3}/sql"
  local l_extension="${4}"
  local l_only_scripts="${5}"
  local l_sha="${6}"
  local l_repo_dir="${7}"
  local l_git_dir="${l_repo_dir}/.git"
  local l_version_db
  local l_sha_db
  local l_filters


  is_need_install_(){
    local l_filters_cnt
    
    if [ -n "${l_sha_db}" ]; then
      if [[ "$(git --git-dir=${l_git_dir} cat-file -t ${l_sha_db} 2>/dev/null)" != "commit" ]]; then
        raise "SHA DB not a valid object name"
      fi
      if [[ "${l_sha}" == "${l_sha_db}" ]]; then
        out "CHECK SHA: DB version of extension is already installed to DB"
        return 1
      fi
      #out "git --git-dir=${l_git_dir} merge-base --is-ancestor ${l_sha_db} ${l_sha}"
      #GIT VERSION 1.8 ( if [[ "$(git --git-dir=${l_git_dir} merge-base --is-ancestor ${l_sha_db} ${l_sha})" == "1" ]]; then
      #out "git --git-dir=${l_git_dir} merge-base ${l_sha_db} ${l_sha}"
      if [[ "${l_sha_db}" != "$(git --git-dir=${l_git_dir} merge-base ${l_sha_db} ${l_sha})" ]]; then
        out "CHECK SHA: DB version of extension isn't ancestor of current, the installing is impossible"
        return 1
      fi
    fi

    if compare_version "${l_version_db}" "${l_version_repo}"; then
      if ! check_dependences "${l_extension_dir}"; then
        out "Checking dependencies is fail. Install required extensions and retry"
        return 1
      fi
    else
      out "There isn't new version in repo."
      return 1
    fi

    create_filters "${l_repo_dir}" "${l_extension_dir}" "${l_sha}" "${l_sha_db}" "${l_filters}"
    l_filters_cnt=$(cat "${l_filters}" | wc -l)
    if [[ "${l_filters_cnt}" == "0" ]]; then
      out "!!! ATTENTION !!! Filters is empty"
      return 1
    fi
    
    return 0
  }


  export TWO_TASK=${l_target_db}
  l_filters="${l_extension_dir}/_filters_${TWO_TASK}"

  
  out "Target: ${l_target_db}, TWO_TASK: ${TWO_TASK}"

  check_version

  request_ora "GET_VERSION" "${l_extension}"
  l_version_db="${__result}"
  out "DB Version : ${l_version_db}, REPO version: ${l_version_repo}"
  
  request_ora "GET_COMMIT_SHA" "${l_extension}"
  l_sha_db="${__result}"

  out "DB SHA : ${l_sha_db}, REPO SHA: ${l_sha}"
  
  #compare_version "${l_version_db}" "${l_version_repo}"
    
  if is_need_install_; then
    install_extension "${l_extension_dir}" "${l_filters}" "${l_only_scripts}"
    if [[ "${l_only_scripts}" == "N" ]]; then
      request_ora "REGISTER" "${l_extension}" "${l_version_repo} ${l_sha}"
      rm -f "${l_filters}"
    fi
  else
    out 'Install was skipped'
  fi

}

compare_version(){
  local l_version_db="${1}"
  local l_version_repo="${2}"

  local l_piece_db
  local l_piece_repo
  local l_result=1

  if [[ -z "${l_version_db}" ]]; then
    return 0
  fi
  
  out "Compare exists version ${l_version_db} with required version ${l_version_repo}"
  
  for i in 1 2 3; do
    l_piece_db="$(echo ${l_version_db} | cut -d. -f ${i})"
    l_piece_repo="$(echo ${l_version_repo} | cut -d. -f ${i})"
    #out "${l_piece_repo} ${l_piece_db}"
    if (( ${l_piece_repo} > ${l_piece_db} )); then
      l_result=0
      #out "Repo more than DB"
    elif (( ${l_piece_repo} < ${l_piece_db} )); then
      break
      #out "Repo less than DB"
    fi
  done
  
  return $l_result
}

clone_repo(){
  local l_repo="${1}"
  local l_repo_dir="${2}"
  local l_checkout="${3}"

  if [[ -d "${l_repo_dir}" ]]; then
    out "Repo folder ${l_repo_dir} already exists and the cloning will be skip"
  else
    set_error "The clone of repository is failed"
    git clone "${l_repo}" "${l_repo_dir}"
    out "The clone of repository (${l_repo}) have been create: ${l_repo_dir}"
  fi
  
  cd "${l_repo_dir}"
  if [[ -z "${l_checkout}" ]]; then
    out "The switching is skipped"
  else
    set_error "Switching to ${l_checkout} fail"
    git checkout "${l_checkout}"
    out "Switching to ${l_checkout} is succesful"
    set_error ""
  fi 
}

parse_parameters(){
  local e_unkn_params=0
  set_error "Parsing parameters is fail"
  while (( "$#" )); do
    key="$1"
    case $key in
      --git-remote)
        l_repo="${2}"
        shift 2
        ;;
      --git-local)
        l_repo_dir="${2}"
        shift 2
        ;;
      --targets)
        l_targets="${2}"
        shift 2
        ;;
      --checkout)
        l_checkout="${2}"
        shift 2
        ;;
      --only-scripts)
        l_only_scripts='Y'
        shift
        ;;
      --)
       shift
       break
       ;;
      *)
        echo "Unknown parameter ${1} will skip"
        e_unkn_params=$(( e_unkn_params + 1 ))
        shift
        ;;
    esac
  done
  
  if (( ${e_unkn_params} > 0 )); then
    raise "It found unknown parameter(s): ${e_unkn_params}. Check and rerun again"
  fi
  l_only_scripts="${l_only_scripts-N}"
  set_error "The extension code must not be empty"
  l_extension="${1}"
  set_error ""

  l_targets="${l_targets-DEV}"
  l_checkout="${l_checkout:-}"

  out "Extension: ${l_extension}"
  out "Targets DB: ${l_targets}"
  out "Repo dir: ${l_repo_dir:-}"
  out "Remote repo: ${l_repo}"
  out "Checkout: ${l_checkout}"
  set_error ""
}
