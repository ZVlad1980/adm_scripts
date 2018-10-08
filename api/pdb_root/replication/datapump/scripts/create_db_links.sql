create shared database link fnd_testdb
connect to fnd identified by "3edc>lo9"
authenticated by fnd identified by "3edc>lo9"
using '(DESCRIPTION = (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = 10.1.1.108)(PORT = 1521))) (CONNECT_DATA = (SERVICE_NAME=tstdb)))'
/
create shared database link cdm_testdb
connect to cdm identified by "cdm"
authenticated by cdm identified by "cdm"
using '(DESCRIPTION = (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = 10.1.1.108)(PORT = 1521))) (CONNECT_DATA = (SERVICE_NAME=tstdb)))'
/
create shared database link gazfond_testdb
connect to gazfond identified by "test_123"
authenticated by gazfond identified by "test_123"
using '(DESCRIPTION = (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = 10.1.1.108)(PORT = 1521))) (CONNECT_DATA = (SERVICE_NAME=tstdb)))'
/
--drop database link fnd_testdb
