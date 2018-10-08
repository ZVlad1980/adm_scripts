#!/usr/bin/sh +x
#
# Script to clone db up to given SCN.
#
##############################################
DIR=`dirname $0`
if [ `expr substr $DIR 1 1` = "." ]; then DIR=`pwd`; fi
#----------------------------------------------------------------------
src_file()                # Sources all given .sh files from dir.
#----------------------------------------------------------------------
# 1-n arg: fil - names of files to source(w/o extn).
{
  for _FIL; do . ${DIR}/${_FIL}.sh; done
}
#----------------------------------------------------------------------
mak_cln_scr()             # Makes RMAN script to clone db.
#----------------------------------------------------------------------
# 1 arg: tpl - name of template file.
# 2 arg: scr - name of script to create.
# 3 arg: trg - DB name of source DB.
# 4 arg: aux - DB name of clone DB.
# 5 arg: tim - time to clone up to.
# 6 arg: loc - backup location.
# 7 arg: dir - directory for ORLs.
#[8 arg: orl - number of orl files to create.]
#[9 arg: siz - size of orl files to create.]
{
  _SCR=$2
  _TRG=$3
  _AUX=$4
  _TIM=$5
  _LOC=$6
  _DIR=$7
  _RLN=${8:-3}
  _RLS=${9:-128M}
  # Copy start of script.
  rm -f $_SCR
  cp -p $1 $_SCR
  _LEN=`expr length "$_TIM"`
  if [ ${_LEN} -gt 8 ]; then
    echo "    DUPLICATE DATABASE '"${_TRG}"' TO '"${_AUX}"'" >> $_SCR
    echo "     UNTIL TIME \""${_TIM}"\"" >> $_SCR
  fi
  echo "    BACKUP LOCATION '"${_LOC}"'" >> $_SCR
  echo "    LOGFILE" >> $_SCR
  _ORL=1
  while [ $_ORL -le $_RLN ]
  do
    _GRP="GROUP "$_ORL" ('"$_DIR"/log0"$_ORL".log') SIZE "$_RLS" REUSE"
    if [ $_ORL -ne $_RLN ]; then _CHR=","; else _CHR=";"; fi
    echo "      "${_GRP}${_CHR} >> $_SCR
    _ORL=`expr $_ORL + 1`
  done 
  echo " RELEASE CHANNEL ch1;" >> $_SCR
  echo "}" >> $_SCR
  echo "exit" >> $_SCR
  unset _SCR _AUX _TRG _TIM _DIR _RLN _RLS _ORL _CHR _GRP _LEN _LOC
  return 0
}
#****************************************#
# BEGIN - read in all necessary scripts. #
#****************************************#
cd $DIR
src_file conf_clon chkfildir chkerrcod setoraenv runtimcmd
#------------------------------------------------------
# Check that all vars defined and all files/dirs exist.
#------------------------------------------------------
ERR_MSG="Not all necessary variables defined!!!"
if ! chk_vars; then echo $ERR_MSG; exit 101; fi
#-------------------------------------------
# Check number of arguments (must be 1).
#-------------------------------------------
USAGE="  Usage: `basename $0` date_time"
if [ $# -ne 1 ]; then echo $USAGE; exit 1; fi
#---------------------------------
# Set parameters.
#---------------------------------
UTIME=$1
set_ora_env $SID $HOM
# Set variables.
SPFILE=${HOM}/dbs/spfile${SID}.ora
# Script Logfiles:
RMNLOG="logs/rman"`date +%y%m%d`".log"
SQLLOG="logs/sql"`date +%y%m%d`".log"
#---------------------------------
# Stop database.
#---------------------------------
_MSG="Shutting listener..."
RUNCMD="lsnrctl stop listener_$SID"
run_tim_cmd "$RUNCMD" "$_MSG" 2 + $SQLLOG
_MSG="Shutdown database..."
RUNCMD="sqlplus -s /nolog @shut_imm.sql"
run_tim_cmd "$RUNCMD" "$_MSG" 3 + $SQLLOG
#---------------------------------
# Remove SPFILE and db files.
#---------------------------------
_MSG="Remove db files....."
RUNCMD="rm -f $SPFILE"
RUNCMD="$RUNCMD"" && rm -f ${DBSDIR}/*.dbf"
RUNCMD="$RUNCMD"" && rm -f ${CTLDIR}/*.ctl"
RUNCMD="$RUNCMD"" && rm -f ${RDODIR}/*.log"
run_tim_cmd "$RUNCMD" "$_MSG" 4 + $SQLLOG
#---------------------------------
# Start database NOMOUNT.
#---------------------------------
_MSG="Starting database..."
RUNCMD="sqlplus -s /nolog @runnomnt.sql"
run_tim_cmd "$RUNCMD" "$_MSG" 5 + $SQLLOG
#---------------------------------
# Make and run rman clone script.
#---------------------------------
mak_cln_scr clonedb.tpl clonedb.rman $DBO $DBN "$UTIME" $BKPDIR $RDODIR 4 1G
_MSG="Clone db by RMAN...."
RUNCMD="rman @clonedb.rman log $RMNLOG"
run_tim_cmd "$RUNCMD" "$_MSG" 4 - NUL
ERRCODE=$?
#---------------------------------
# Perform post-clone actions.
#---------------------------------
_MSG="Post-clone actions.."
RUNCMD="sqlplus -s /nolog @postclon.sql"
if [ $ERRCODE -eq 0 ]; then
  run_tim_cmd "$RUNCMD" "$_MSG" 5 + $SQLLOG
  ERRCODE=$?
  #----------------
  # Start listener.
  #----------------
  if [ $ERRCODE -eq 0 ]; then
    _MSG="Starting listener..."
    RUNCMD="lsnrctl start listener_$SID"
    run_tim_cmd "$RUNCMD" "$_MSG" 6 + $SQLLOG
  fi
fi
#---------------------------------
# FINISH
#---------------------------------
exit 0
