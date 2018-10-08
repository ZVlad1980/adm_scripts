#! /usr/bin/bash
find /ora1/admin/tstcdb/adump -name '*.aud' -ctime +7 -exec rm {} \;
find /ora1/12_1_0/rdbms/audit -name '*.aud' -ctime +7 -exec rm {} \;
find /ora1/grid/rdbms/audit -name '*.aud' -ctime +7 -exec rm {} \;
