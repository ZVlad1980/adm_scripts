############################################
# This script contains definitions for main 
# variables and function to check whether 
# all variables are defined - chk_vars.
############################################
#------------------------------------
# SID DBNAME and ORA_HOME:
#------------------------------------
SID=tstdb
DBN=tstdb
HOM=/ora1/12_1_0
#------------------------------------
# Original DBNAME:
#------------------------------------
DBO=FONDDB
#--------------------------------------
# Instance data and backup directories:
#--------------------------------------
DBSDIR=/ora1/dat/${SID}/dbs
CTLDIR=/ora1/dat/${SID}/ctl
RDODIR=/ora1/dat/${SID}/redo
BKPDIR=/ora1/sav/bkup
#-------------------------------------------
# Debug level.
#  NOTE:
#    0 - leave only main logs.
#    1 - leave more logs.
#    2 - leave temporary SQL files.
#    3 - only echo commands, don't execute.
#-------------------------------------------
if [ x$DEBUG = x ]; then DEBUG=1; fi
#----------------------------------------------------------------------
chk_vars()                # Checks that neccessary variables defined.
#               NOTE:  Don't forget to modify upon adding new vars!!!
#----------------------------------------------------------------------
# No arguments.
{
  if [ -z ${SID:-""} ];    then return 1; fi
  if [ -z ${HOM:-""} ];    then return 1; fi
  if [ -z ${DBN:-""} ];    then return 1; fi
  if [ -z ${DBO:-""} ];    then return 1; fi
  if [ -z ${DBSDIR:-""} ]; then return 1; fi
  if [ -z ${CTLDIR:-""} ]; then return 1; fi
  if [ -z ${RDODIR:-""} ]; then return 1; fi
  return 0
}
