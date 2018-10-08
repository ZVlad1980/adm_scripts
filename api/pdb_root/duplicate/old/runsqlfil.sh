#-------------------------------------------------------------------------
run_sql_fil()             # Runs given sql script.
#-------------------------------------------------------------------------
#  1 arg: fse - flag to fail on sql error (Y-set/N-don't set).
#  2 arg: foe - flag to fail on os  error (Y-set/N-don't set .
#  3 arg: fbk - flag to set feedback option (N-off/Y-on).
#  4 arg: hdg - flag to set heading option (N-off/Y-on).
#  5 arg: tsp - flag to set trimspool option (Y-on/N-off).
#  6 arg: lsz - linesize for output (N-don't set/number-set).
#  7 arg: usr - user to connect to database.
#  8 arg: pwd - user's password.
#  9 arg: als - alias for db to connect("-" - local db).
# 10 arg: log - log file to store output ("-" - no log file).
#[11 arg: sql - script file to run (if absent - from stdin).]
{
  #-----------------------------
  # Check params and debug flag.
  #-----------------------------
  if [ $# -lt 9 ]
  then
    echo "Usage:"
    echo "  run_sql_fil sql_err_fail os_err_fail feedback heading trimspool"
    echo "          linsiz usr passwd alias logfil [sql par1...parN]"
    return 111
  fi
  if [ ${DEBUG:-0} -ge 3 ]; then echo "run_sql_fil "$*; _RET=0; return $_RET; fi
  #--------------------------
  # Build temporary sql file.
  #--------------------------
  _FIL=run_sql.sql
  rm -f $_FIL
  # Set options from params.
  if [ $1 = Y ];  then echo "whenever sqlerror exit failure" >> $_FIL; fi
  if [ $2 = Y ];  then echo "whenever oserror exit failure"  >> $_FIL; fi
  if [ $3 = N ];  then echo "set feedback off" >> $_FIL; fi
  # If params to script given disable verify option.
  if [ $# -gt 9 ];  then echo "set verify off" >> $_FIL; fi
  if [ $4 = N ]; then 
    echo "set heading off" >> $_FIL; echo "set pagesize 0" >> $_FIL;
  fi
  if [ $5 = Y ];  then echo "set trimspool on" >> $_FIL; fi
  if [ $6 != N ]; then echo "set linesize $6"  >> $_FIL; fi
  # Check if connect to local db.
  if [ $9 = - ]
  then
    echo "connect $7/$8" >> $_FIL
  else
    echo "connect $7/$8@$9" >> $_FIL
  fi
  # Save names for log and sql files.
  shift 2
  _LOG=$8
  _SQL="${9:--}"
  # Check if we need spooling.
  if [ $_LOG != - ]; then echo "spool $_LOG" >> $_FIL; fi
  # Check if param-file or string with sql or stdin.
  if [ "$_SQL" != - ]
  then
    # Sql param is set.
    if [ -s "$_SQL" ]
    then 
      cat $_SQL    >> $_FIL
      shift 9
    else 
      echo "$_SQL" >> $_FIL
    fi
  else
    # Read sql lines from stdin.
    while read _LIN; do echo $_LIN >> $_FIL; done
  fi
  if [ $_LOG != - ]; then echo "spool off" >> $_FIL; fi
  echo "exit" >> $_FIL
  #--------------------------------------
  # At last run built file and remove it.
  #--------------------------------------
  sqlplus -s /nolog @$_FIL $* >/dev/null 2>&1
  _RET=$?
  if [ ${DEBUG:-0} -le 1 ]; then rm -f $_FIL; fi
  unset _FIL _LIN _LOG _SQL
  return $_RET
}
