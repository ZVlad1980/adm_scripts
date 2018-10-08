#! /bin/bash

pwd_curr=`pwd`


sqlplus /nolog @install.sql $1

cd $pwd_curr

mkdir -p /home/oracle/tstcdb
mkdir -p /home/oracle/tstcdb/pdb_daemon
mkdir -p /home/oracle/tstcdb/pdb_daemon/clone

cp BashScripts/* /home/oracle/tstcdb/pdb_daemon/clone
chmod 774 /home/oracle/tstcdb/pdb_daemon/clone/*.sh
