#----------------------------------------------------------------------
chk_file()                # Checks that all files exist.
#----------------------------------------------------------------------
# 1-n arg: fil - filenames to check.
{
  for _FIL
  do
    _ERRMSG="File \""$_FIL"\" not found!!!"
    if [ ! -s $_FIL ]; then echo $_ERRMSG; unset _FIL _ERRMSG; return 1; fi
  done
  unset _FIL _ERRMSG
  return 0
}
#----------------------------------------------------------------------
chk_dirs()             # Checks that all dirs exist.
#----------------------------------------------------------------------
# 1-n arg: dir - dirs to check.
{
  for _DIR
  do
    _ERRMSG="Directory \""$_DIR"\" not found!!!"
    if [ ! -d $_DIR ]; then echo $_ERRMSG; unset _DIR _ERRMSG; return 1; fi
  done
  unset _DIR _ERRMSG
  return 0
}
