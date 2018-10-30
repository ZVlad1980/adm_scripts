#!/usr/bin/env bash

duplicate(){
  local -r target_db="${1:-}"
  local -r src_host="oracle@10.1.1.108"
  local -r src_dmp_path="/ora1/buf/datapump/tts"
  local -r src_file_path="/ora1/dat/tstdb/dbs"
  local -r export_file="export.dmp"
  local -r import_file="export.dmp"
  local -r import_log="import_$(date +%y%m%d).log"
  local -r signal_file="tts_ready_$(date +%y%m%d)"
  local -r sqldir="${__dir}/sql"
  local -r logdir="${__dir}/logs"
  local -r confdir="${__dir}/conf"
  local -r rmnlog="${__dir}/logs/rman_$(date +%y%m%d)_$(date +%H%M).log"
  #local -r cnvlog="${__dir}/logs/conv_"`date +%y%m%d`"_"`date +%H%M`".log"
  local -r backup_path="/u01/app/oracle/backup/aix_files"
  local -r dmp_path="/u01/app/oracle/buf/datapump/tts"

  out "Starting update ${target_db}"
  
  check_signal
  
  out "Copy datafiles and datapump file from IBM02"
  copy_files
  out "Copy complete"

  out "Recreate ${target_db}"
  recreate_node
  out "Recreate complete"
  
  out "Convert datafiles"
  convert_datafiles
  out "Convert complete"

  out "Import metadata into ${target_db}"
  import_dmp
  out "Import complete"
  
  out "Post import process"
  post_import
  out "Post import complete"
  
  out "${target_db} updating is complete"

}

run_sql(){
  local file="${1}"
  shift
  local sqlfile="${sqldir}/${file}.sql"
  local logfile="${logdir}/sql_${file}_$(date +%y%m%d)_$(date +%H%M).log"
  if [ -f "${sqlfile}" ]
  then
    out "Run @${sqlfile}, logout: ${logfile}"
    sqlplus /nolog @"${sqlfile}" "$@" &> "${logfile}" 
    out "Complete ${sqlfile}"
  else
    raise "Script ${sqlfile} not found!"
  fi
}

scp_from(){
  scp_copy "${src_host}:${1}" "${2}"
}

check_signal(){
  scp_from "${src_dmp_path}/${signal_file}" "${logdir}/"
}

copy_files(){
  rm -f "${dmp_path}/${import_file}"
  rm -f "${dmp_path}/${import_log}"
  rm -f "${backup_path}/"*
  scp_from "${src_file_path}/arh*" "${backup_path}/"
  scp_from "${src_file_path}/ctx*" "${backup_path}/"
  scp_from "${src_file_path}/dwh*" "${backup_path}/"
  scp_from "${src_file_path}/inf*" "${backup_path}/"
  scp_from "${src_file_path}/mdm*" "${backup_path}/"
  scp_from "${src_file_path}/ops*" "${backup_path}/"
  scp_from "${src_file_path}/web*" "${backup_path}/"
  scp_from "${src_file_path}/f*" "${backup_path}/"
  scp_from "${src_file_path}/g*" "${backup_path}/"
  scp_from "${src_file_path}/smppdat01*" "${backup_path}/"
  scp_from "${src_file_path}/usr*" "${backup_path}/"
  scp_from "${src_file_path}/etl*" "${backup_path}/"
  
  scp_from "${src_dmp_path}/${export_file}" "${dmp_path}/export.dmp"

  run_sql "set_tablespace_online"

}

recreate_node(){
  run_sql "drop_node" "${target_db}"
  sleep 30 #????
  run_sql "stop_daemon"
  run_sql "shut_tstcdb"
  wait_clean_snaps "dev"
  wait_clean_snaps "weekly"
  run_sql "start_tstcdb"
  out "Start PDB_DAEMON"
  "${__dir}"/start_daemon.sh
  run_sql "create_${target_db}" "${dmp_path}"
}

convert_datafiles(){
  rman target / @"${confdir}/convert_${target_db}.rman" LOG="${rmnlog}" &>> /dev/null
}

import_dmp(){
  run_sql "open_node" "${target_db}"
  set +e
  impdp system/passwd@"${target_db}" parfile="${confdir}/imp_${target_db}.par" logfile="${import_log}" &>> "${logdir}/${import_log}"
  set -e
  #TODO Add check result import
}

post_import(){
  run_sql "post_import" "${target_db}"
}
