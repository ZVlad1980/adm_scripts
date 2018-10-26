sqlplus / as sysdba "@${DIR}/open_node.sql" ${TARGET}
echo Open ${TARGET}
impdp system/"passwd"@${TARGET} parfile="${DIR}/imp_${TARGET}.par" logfile="import_${TARGET}.log"
