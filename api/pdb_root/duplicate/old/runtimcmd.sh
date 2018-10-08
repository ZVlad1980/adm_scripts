#----------------------------------------------------------------------
run_tim_cmd()             # Runs given command and prints time report.
#----------------------------------------------------------------------
# 1 arg: cmd - command line to run.
# 2 arg: msg - start of message to output.
# 3 arg: cod - code to return in case of error.
#[4 arg: add - flag to add output (+ add/- not add).]
#[5 arg: out - where to send output of cmd (NUL-/dev/null).]
#[6 arg: inp - string to input to cmd (only to provide pass for imp).]
{
  _CMD=$1
  _MSG=$2
  _RET=$3
  _ADD=${4:-"-"}
  _OUT=${5:-""}
  _INP=${6:-NUL}
#!if [ ${DEBUG:-0} -ge 3 ]; then echo "run_tim_cmd "$*; _RET=0; return $_RET; fi
  if [ ${DEBUG:-0} -ge 2 ]
  then 
    echo "run_tim_cmd "$* 
    if [ ${DEBUG:-0} -ge 3 ]
    then
      _RET=0
      return $_RET
    fi
  fi
  _BEG=`date +"%H:%M:%S"`
  if [ $# -gt 3 ]
  then 
    if [ $_INP != NUL ]
    then
      if [ $_OUT = NUL ]
      then
        $_CMD >/dev/null 2>&1 <<EndOfFile1
          $_INP
EndOfFile1
      else
        if [ $_ADD = "+" ]; then
          $_CMD >> $_OUT <<EndOfFile2
            $_INP
EndOfFile2
        else
          $_CMD > $_OUT <<EndOfFile3
            $_INP
EndOfFile3
        fi
      fi
    else
      if [ $_OUT = NUL ]
      then 
        $_CMD >/dev/null 2>&1
      else
        if [ $_ADD = "+" ]; then $_CMD >> $_OUT; else $_CMD > $_OUT; fi
      fi
    fi
  else 
    $_CMD
  fi
  _ERR=$?
  if [ $_ERR -ne 0 ]
  then
      case $_CMD in
         impdp*)
               if [ $_ERR -eq 5 ]; then _MSG=${_MSG}" OK!"; _ERR=0; fi;;
              *) _MSG=${_MSG}" ERR: $_ERR!!!" ;;
      esac
  else
      _MSG=${_MSG}" OK!"
  fi
  echo "$_BEG - `date +"%H:%M:%S"` ... $_MSG"
  if [ $_ERR -eq 0 ]; then _RET=0; fi
  unset _MSG _CMD _OUT _INP _BEG _ERR 
  return $_RET
}
