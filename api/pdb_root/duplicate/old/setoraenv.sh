#----------------------------------------------------------------------
set_ora_env()             # Sets Oracle environment.
#----------------------------------------------------------------------
# 1 arg: sid - oracle SID to work with.
# 2 arg: hom - oracle HOME to work with.
{
  export ORACLE_SID=$1
  export ORACLE_HOME=$2
  export NLS_LANG=AMERICAN_CIS.CL8MSWIN1251
  PATH=$PATH:$ORACLE_HOME/bin
  LIBPATH=/opt/freeware/lib:$LIBPATH
  return 0
}
