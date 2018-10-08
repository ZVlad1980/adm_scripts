#! /usr/bin/bash
. /home/oracle/.profile 
. /home/oracle/.cdb_env
nohup sqlplus /nolog @./start_daemon.sql & 
