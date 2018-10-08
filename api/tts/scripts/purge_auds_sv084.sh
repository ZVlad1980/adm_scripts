find /u01/app/oracle/admin/tstcdb/adump -name '*.aud' -ctime +7 -exec rm {} \;
find /u01/app/oracle/product/12.2.0/grid/rdbms/audit -name '*.aud' -ctime +7 -exec rm {} \;
find /u01/app/oracle/diag -name '*.tr*' -ctime +7 -exec rm {} \;





