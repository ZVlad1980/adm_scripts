#! /usr/bin/bash
. /home/oracle/.bash_profile 
. /home/oracle/.cdb_env
sqlplus /nolog @./restart.sql
nohup sqlplus /nolog @./start_daemon.sql & 
