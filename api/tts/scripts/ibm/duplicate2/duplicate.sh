#!/usr/bin/env bash

duplicate(){
  local -r target_db="${1:-}"
  local -r signal_file="tts_ready_$(date +%y%m%d)"
  local -r sqldir="${__dir}/sql"
  local -r confdir="${__dir}/conf"
  local -r logdir="${__dir}/logs"
  local -r rmnlog="${__dir}/logs/rman_$(date +%y%m%d)_$(date +%H%M).log"
  local -r cnvlog="${__dir}/logs/conv_$(date +%y%m%d)_$(date +%H%M).log"
  local -r prepttslog="${__dir}/logs/prep_tts_$(date +%y%m%d)_$(date +%H%M).log"
  local -r backup_path="/ora1/sav/bkup"
  local -r dump_dir="/ora1/buf/datapump/tts"
  local -r dump_file="export.dmp"
  local -r dump_log="export_tts_$(date +%y%m%d).log"
  local -r xml_file="${confdir}/xml/tstdb.xml"
  mkdir -p "${confdir}/xml"

  out "Duplicate start for ${target_db}"
  if [ $(find "${backup_path}" ! -path "${backup_path}" -prune -type f | wc -l) -eq 0 ]
  then
    set_error "Backup not found. Directory /ora1/sav/bkup/ is empty."
    exit 1;
  fi  

  out "Prepare duplicate"
  prepare_duplicate
  out "Prepare complete"

  out "Duplicate DB"
  create_duplicate
  out "Duplicate complete"

  out "Post duplicate"
  post_duplicate
  out "Post duplicate complete"

  out "Plugin TSTDB to TSTCDB"
  noncdb_to_cdb
  out "Plugin complete"

  out "Prepare TTS"
  prepare_tts
  out "Complete prepare TTS"

  create_signal
  out "DUPLICATE COMPLETE"

  # Action will remove to SV084. nohup "${__dir}/finalizer.sh" "${target_db}" "${sqldir}/online.sql" "${dump_dir}/${signal_file}" &> "${finlog}" &

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

prepare_duplicate(){
  set_ora "tstcdb"
  run_sql "drop_tstdb"
  rm -fr /ora1/dat/tstdb/arc/*
  rm -fr /ora1/dat/tstdb/ctl/*
  rm -fr /ora1/dat/tstdb/redo/*
  rm -fr /ora1/dat/tstdb/dbs/*
  rm -f /ora1/12_1_0/dbs/spfiletstdb.ora
  rm -f "${dump_dir}/${dump_file}"
  rm -f "${dump_dir}/${dump_log}"
  rm -f "${dump_dir}/${signal_file}"
}

create_duplicate(){
  set_ora "tstdb"
  cp "${confdir}/init/"* "${ORACLE_HOME}/dbs/"
  run_sql "startup_auxiliary" "${ORACLE_HOME}/dbs/inittstdb.ora"
  rman @"${confdir}/duplicate_db.rman" log "${rmnlog}"
  out "####"
}

post_duplicate(){
  set_ora "tstdb"
  run_sql "post_duplicate"
}

noncdb_to_cdb(){
  rm -f /home/oracle/tstcdb/tstdb.xml
  set_ora "tstdb"
  run_sql "prepare_plugin" "${xml_file}"
  set_ora "tstcdb"
  out "Apply plugin_to_tstcdb 1 RUN"
  run_sql "plugin_to_tstcdb" "${xml_file}"
  out "Apply plugin_to_tstcdb 2 RUN"
  run_sql "plugin_to_tstcdb2"
}

prepare_tts(){
  set_ora "tstcdb"
  run_sql "prepare_tts" "${dump_dir}"
  out "Datapump export start"
  set +e
  expdp system/passwd@tstdb full=y dumpfile="${dump_file}" directory=data_dump_dir transportable=always logfile="${dump_log}" &> "${logdir}/${dump_log}"
  set -e
  if [ $(tail -1 "${dump_dir}/${dump_log}" | grep -c 'completed with 4 error(s)') -eq 0 ]
  then 
    raise "Export TTS failed. Detail log: ${dump_dir}/${dump_log}"
  fi
  out "Datapump export complete"
}

create_signal(){
  echo "TTS COMPLETE:" > "${dump_dir}/${signal_file}"
}