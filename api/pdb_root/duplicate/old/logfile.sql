column member format a40
select 
  GROUP# grp,
  STATUS stat,
  TYPE,
  MEMBER,
  IS_RECOVERY_DEST_FILE irdf
 from 
  v$logfile;
