#! /usr/bin/bash
. /home/oracle/.profile 
. /home/oracle/.cdb_env
sqlplus /nolog @./stop_daemon.sql
