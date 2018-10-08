select name, cdb, con_id from v$database
/
select instance_name, status, con_id from v$instance;
/
select dbms_xdb_config.getHTTPsPort() https_port from dual;
/
begin dbms_xdb_config.setHTTPsPort(5501); end;
/
begin
  dbms_xdb_config.setHTTPPort(5500);
end;
/
--http://www.oracle.com/webfolder/technetwork/tutorials/obe/db/12c/r1/2day_dba/12cr1db_ch3emexp/12cr1db_ch3emexp.html
lsnrctl status
/
sqlplus:
show parameter dispatchers
