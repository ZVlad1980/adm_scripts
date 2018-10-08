select name, cdb, con_id, db.LOG_MODE ,
       db.*
from   v$database db
/
select instance_name, status, con_id , 
       n.*
from   v$instance n;
/
select dbms_xdb_config.getHTTPsPort() https_port
from   dual
/
select * from registry$history;
/
/*
begin
  dbms_xdb_config.setHTTPsPort(5501);
end;
*/
