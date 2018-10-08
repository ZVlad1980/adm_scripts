#-------------------------------------------------------------------------
chk_err_cod()             # Checks error code and returns, removing file.
#                           and setting externally defined var ERRCODE.
#-------------------------------------------------------------------------
# 1 arg: cod - error code to test.
#[2-n arg: fil - file(s) to delete.]
{
  ERRCODE=$1
  shift
  if [ $# -gt 0 ]; then rm -f $*; fi
  return $ERRCODE
}
