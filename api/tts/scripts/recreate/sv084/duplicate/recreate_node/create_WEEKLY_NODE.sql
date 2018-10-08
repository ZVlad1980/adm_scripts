host rm -fr /u01/app/oracle/oradata/weekly/WEEKLY_NODE/datafile
create pluggable database weekly_node admin user admin identified by admin file_name_convert=(
  '/u01/app/oracle/oradata/tstcdb/pdbseed/system01.dbf', '/u01/app/oracle/oradata/weekly/WEEKLY_NODE/datafile/system01.dbf',
  '/u01/app/oracle/oradata/tstcdb/pdbseed/sysaux01.dbf', '/u01/app/oracle/oradata/weekly/WEEKLY_NODE/datafile/sysaux01.dbf',
  '/u01/app/oracle/oradata/tstcdb/pdbseed/temp01.dbf', '/u01/app/oracle/oradata/tempfiles/weekly_node_temp01.dbf'
);
alter pluggable database weekly_node open;
alter session set container=weekly_node;
ALTER DATABASE TEMPFILE '/u01/app/oracle/oradata/tempfiles/weekly_node_temp01.dbf' RESIZE 5G;
ALTER DATABASE TEMPFILE '/u01/app/oracle/oradata/tempfiles/weekly_node_temp01.dbf' autoextend on maxsize 5G;
ALTER DATABASE dataFILE '/u01/app/oracle/oradata/weekly/WEEKLY_NODE/datafile/system01.dbf' RESIZE 9G;
ALTER DATABASE dataFILE '/u01/app/oracle/oradata/weekly/WEEKLY_NODE/datafile/sysaux01.dbf' RESIZE 1G;
CREATE OR REPLACE FUNCTION vrf_func_12c
(username varchar2,
 password varchar2,
 old_password varchar2)
RETURN boolean IS
   differ integer;
   pw_lower varchar2(256);
   db_name varchar2(40);
   i integer;
   simple_password varchar2(10);
   reverse_user varchar2(32);
BEGIN
   IF NOT complexity_check(password, chars => 8, letter => 1, digit => 1) THEN
      RETURN(FALSE);
   END IF;

   -- Check if the password contains the username
   pw_lower := NLS_LOWER(password);
   IF instr(pw_lower, NLS_LOWER(username)) > 0 THEN
     raise_application_error(-20002, 'Password contains the username');
   END IF;

   -- Check if the password contains the username reversed
  reverse_user := '';
  FOR i in REVERSE 1..length(username) LOOP
    reverse_user := reverse_user || substr(username, i, 1);
  END LOOP;
  IF instr(pw_lower, NLS_LOWER(reverse_user)) > 0 THEN
    raise_application_error(-20003, 'Password contains the username ' ||
                                    'reversed');
  END IF;

  -- Check if the password contains the server name
  select name into db_name from sys.v$database;
  IF instr(pw_lower, NLS_LOWER(db_name)) > 0 THEN
     raise_application_error(-20004, 'Password contains the server name');
  END IF;

  -- Check if the password contains 'oracle'
  IF instr(pw_lower, 'oracle') > 0 THEN
       raise_application_error(-20006, 'Password too simple');
  END IF;

  -- Check if the password is too simple. A dictionary of words may be
  -- maintained and a check may be made so as not to allow the words
  -- that are too simple for the password.
  IF pw_lower IN ('welcome1', 'database1', 'account1', 'user1234',
                              'password1', 'oracle123', 'computer1',
                              'abcdefg1', 'change_on_install') THEN
      raise_application_error(-20006, 'Password too simple');
   END IF;

   -- Check if the password differs from the previous password by at least
   -- 3 characters
   IF old_password IS NOT NULL THEN
     differ := string_distance(old_password, password);
     IF differ < 3 THEN
        raise_application_error(-20010, 'Password should differ from the '
                                || 'old password by at least 3 characters');
     END IF;
   END IF ;

   RETURN(TRUE);
END;
/
connect system/passwd@weekly_node
CREATE OR REPLACE DIRECTORY data_dump_dir AS '/u01/app/oracle/buf/datapump';
exit
