
alter pluggable database orclpdb1 close immediate;
alter pluggable database orclpdb1 open read only;
create pluggable database orclpdb2 from orclpdb1 file_name_convert=('PDB1','PDB2');
alter pluggable database orclpdb1 close immediate;
alter pluggable database orclpdb2 open;
alter pluggable database orclpdb2 save state; 


alter database add logfile group 4 '+CDB/ORCL/ONLINELOG/group_4' size 500M;
alter database add logfile group 5 '+CDB/ORCL/ONLINELOG/group_5' size 500M;
alter database add logfile group 6 '+CDB/ORCL/ONLINELOG/group_6' size 500M;
/*alter database add logfile group 4 '/opt/oracle/oradata/ORCLCDB/redo04.LOG' size 500M;
alter database add logfile group 5 '/opt/oracle/oradata/ORCLCDB/redo05.LOG' size 500M;
alter database add logfile group 6 '/opt/oracle/oradata/ORCLCDB/redo06.LOG' size 500M;
*/
--переключаем группу via sqlplus до 4
alter system switch logfile;
alter system switch logfile;
alter system switch logfile;
alter system checkpoint;
--проверить активную группу:
select group#, (bytes/1024/1024) mbytes, status from v$log;

--удаляем не актуальные группы
alter database drop logfile group 1;
alter database drop logfile group 2;
alter database drop logfile group 3;


connect system@orclpdb2
ALTER DATABASE TEMPFILE '/u01/data/oradata/ORCL/6913FE61BA1B6A42E055E371072A900A/datafile/o1_mf_temp_fdcdcpc9_.dbf' RESIZE 15000m;
ALTER TABLESPACE UNDOTBS1 ADD DATAFILE SIZE 30000M AUTOEXTEND ON NEXT 1000M;
--Проверить undo_management=auto!!!
select segment_name, status from dba_rollback_segs;
--если есть offline:
alter system set undo_management=auto scope=spfile;
--и перегрузить инстанс
cd /u01/data/oradata/NODEPDB/gfdump
impdp system/syspasswd@127.0.0.1:1521/nodepdb \
parfile=imp_cdm_meta.par \
logfile=import_cdm_meta.log

!!! для запуска надо создать таблицу system.drop_indexes (коммент в начале скрипта)
alter_tables.sql --(disable, CDM)

impdp system/syspasswd@127.0.0.1:1521/nodepdb \
parfile=imp_cdm_data.par \
logfile=import_cdm_data.log

impdp system/syspasswd@127.0.0.1:1521/nodepdb \
parfile=imp_gf_meta.par \
logfile=import_gf_meta.log

alter_tables.sql --(disable, GAZFOND)

--Отдельно грузил PEOPLE!
impdp system/syspasswd@127.0.0.1:1521/nodepdb \
parfile=imp_gf_data_people.par \
logfile=import_gf_people.log

impdp system/syspasswd@127.0.0.1:1521/nodepdb \
parfile=imp_gf_data.par \
logfile=import_gf_data.log

impdp system/syspasswd@127.0.0.1:1521/nodepdb \
parfile=imp_fnd_meta.par \
logfile=import_fnd_meta.log

alter_tables.sql --(disable, FND)

impdp system/syspasswd@127.0.0.1:1521/nodepdb \
parfile=imp_fnd_data.par \
logfile=import_fnd_data.log

alter_tables.sql --(enable, <для каждой схемы>)


ALTER DATABASE TEMPFILE '/u01/data/oradata/ORCL/6913FE61BA1B6A42E055E371072A900A/datafile/o1_mf_temp_fdcdcpc9_.dbf' RESIZE 500m;
--удаляем UNDO файл
-- для этого создаем новый undo
create undo tablespace UNDOTBS2 datafile size 1024M;
alter system set undo_tablespace=UNDOTBS2;
alter system set undo_management=MANUAL scope=spfile;
shut immediate
startup
/*
select owner, segment_name, tablespace_name, status from dba_rollback_segs order by 3;
-- if no offline
alter rollback segment "_SYSSMU9_1192467665$" offline;
*/
drop tablespace UNDOTBS1 including contents and datafiles;
alter system set undo_management=auto scope=spfile;
shut immediate
startup
