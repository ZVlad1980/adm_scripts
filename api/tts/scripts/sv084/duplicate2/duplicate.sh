#!/usr/bin/env bash

duplicate(){
  local -r target_db="${1:-}"
  local -r src_host="oracle@10.1.1.108"
  local -r src_dmp_path="/ora1/buf/datapump/tts"
  local -r src_file_path="/ora1/dat/tstdb/dbs"
  local -r export_file="export_tts_$(date +%y%m%d).dmp"
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
  local sqlfile="${sqldir}/${1:-}"
  shift
  if [ -f "${sqlfile}" ]
  then
    out "Run @${sqlfile}"
    sqlplus /nolog @"${sqlfile}" "$@"
    out "Complete ${sqlfile}"
  else
    raise "Script ${sqlfile} not found!"
  fi
}

scp_from(){
  scp_copy "${src_host}:${1}" "${logdir}/"
}

check_signal(){
  scp_from "${src_dmp_path}/${signal_file}" "${logdir}/"
}

copy_files(){
  rm -f "${dmp_path}/${import_file}"
  rm -f "${dmp_path}/${import_log}"
  rm -f "${backup_path}/*"
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

  run_sql "set_tablespace_online.sql"

}

recreate_node(){
  run_sql "drop_node.sql" "${target_db}"
  sleep 30 #????
  run_sql "stop_daemon.sql"
  run_sql "shut_tstcdb.sql"
  wait_clean_snaps "dev"
  wait_clean_snaps "weekly"
  run_sql "start_tstcdb.sql"
  run_sql "start_daemon.sql"
  run_sql "create_${target_db}.sql"  
}

convert_datafiles(){
  rman target / @"${confdir}/convert_${target_db}.rman" LOG="${rmnlog}"
  #TODO Add check result import
}

import_dmp(){
  run_sql "open_node.sql" "${target_db}"
  set +e
  impdp system/passwd@"${TARGET}" parfile="${confdir}/imp_${TARGET}.par" logfile="${import_log}"
  set -e
  #TODO Add check result import
}

post_import(){
  run_sql "post_import.sql" "${target_db}"
}
