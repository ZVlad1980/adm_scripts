#! /usr/bin/bash
. /home/oracle/.bash_profile 
. /home/oracle/.cdb_env
nohup sqlplus /nolog @./start_daemon.sql & 
