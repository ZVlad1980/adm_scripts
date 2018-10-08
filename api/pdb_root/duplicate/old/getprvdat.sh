#----------------------------------------------------------------------
get_prv_dat()             # Returns previous date.
#----------------------------------------------------------------------
# 1 arg: dat - date in format YYMMDD.
#[2 arg: num - num of days before(dft-1,<9).]
{
  # Get parameters.
  DAT=$1
  NUM=${2:-1}
  # Extract date parts.
  DCY=`expr substr $DAT 1 2`
  DCM=`expr substr $DAT 3 2`
  DCD=`expr substr $DAT 5 2`
  DPY=$DCY; DPM=$DCM;
  # Calculate previous date.
  if [ $DCD -le $NUM ]
  then
    if [ $DCM -eq 1 ]
    then
      DPY=`expr $DCY - 1`
      DPM=12
      DPD=`expr 31 + $DCD - $NUM`
    else
      DPM=`expr $DCM - 1`
      DPD=`get_lst_day $DPY $DPM`
      DPD=`expr $DPD + $DCD - $NUM`
    fi
  else
    DPD=`expr $DCD - $NUM`
  fi
  # Output calculated date.
  printf "%02d%02d%02d\n" $DPY $DPM $DPD
  return 0
}
#----------------------------------------------------------------------
get_lst_day()             # Returns last day of month.
#----------------------------------------------------------------------
# 1 arg: yr_ - year of test date.
# 2 arg: mon - month of test date.
{
  # Init vars.
  _LMon="1 3 5 7 8 10 12"; _Days=30
  _Leap=1; _n400=1; _n100=1; _n4=1; 
  # Check whether year is leap.
  if [ `expr $1 % 400` -eq 0 ]; then _n400=0; fi
  if [ `expr $1 % 100` -eq 0 ]; then _n100=0; fi
  if [ `expr $1 % 4` -eq 0 ];   then _n4=0;   fi
  if [ $_n400 -eq 0 -o \( $_n100 -eq 1 -a $_n4 -eq 0 \) ]; then _Leap=0; fi
  # Check long months.
  for I in $_LMon; do if [ $I -eq $2 ]; then _Days=31; break; fi; done
  # Check leap february.
  if [ $2 -eq 2 ]; then _Days=28; if [ $_Leap -eq 0 ]; then _Days=29; fi; fi
  echo $_Days
  return $_Leap
}
