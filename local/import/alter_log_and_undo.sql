-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- Подготовка к импорту
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- Добавляем temp файл
ALTER DATABASE TEMPFILE '/opt/oracle/oradata/ORCLCDB/ORCLPDB2/temp01.dbf' RESIZE 15000m;
--alter tablespace temp add tempfile '/opt/oracle/oradata/ORCLCDB/ORCLPDB2/temp02.dbf' size 10000m reuse autoextend on next 1000m maxsize 20000m
--alter tablespace temp add tempfile '/opt/oracle/oradata/ORCLCDB/ORCLPDB2/temp03.dbf' size 10000m reuse autoextend on next 1000m maxsize 20000m
--alter tablespace temp add tempfile '/opt/oracle/oradata/ORCLCDB/ORCLPDB2/temp02.dbf' size 6000m reuse autoextend on next 500m maxsize 7000m
-- Добавляем UNDO файл
ALTER TABLESPACE UNDOTBS1 ADD DATAFILE '/opt/oracle/oradata/ORCLCDB/ORCLPDB2/undotbs02.dbf' SIZE 30000M AUTOEXTEND ON NEXT 1000M;
--Проверяем и добавляем REDO
--connect with CDB via sqlplus / as sysdba
alter database add logfile group 1 '/opt/oracle/oradata/ORCLCDB/REDO01.LOG' size 500M;
alter database add logfile group 2 '/opt/oracle/oradata/ORCLCDB/REDO02.LOG' size 500M;
alter database add logfile group 3 '/opt/oracle/oradata/ORCLCDB/REDO03.LOG' size 500M;

--При необходимости добавляем файлы в GFNDDATA (актуально при загрузке FND)
ALTER TABLESPACE GFNDDATA ADD DATAFILE '/opt/oracle/oradata/ORCLCDB/ORCLPDB3/gfnddata_04.dat' SIZE 20000M AUTOEXTEND ON NEXT 1000M;
--!!!!!!!!!!!!!!!!!!!
--Проверить undo_management=auto!!!
select segment_name, status from dba_rollback_segs;
alter system set undo_management=auto scope=spfile;
-- !!!!!!
--   Отключаем констрейны и триггера скриптом alter_table_contraints.sql
-- !!!!!!

-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- По завершению импорта
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

-- !!!!!!
--   Включаем констрейны и триггера скриптом alter_table_contraints.sql
-- !!!!!!

-- Удаляем temp файл
ALTER DATABASE TEMPFILE '/opt/oracle/oradata/ORCLCDB/ORCLPDB2/temp01.dbf' RESIZE 500m;
--удаляем UNDO файл
-- для этого создаем новый undo
create undo tablespace UNDOTBS2 datafile  '/opt/oracle/oradata/ORCLCDB/ORCLPDB2/undotbs03.dbf'  size 500M;
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

-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- ВСЕ
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

--http://www.dba-oracle.com/t_pdb_temp_tablespace.htm
--
alter tablespace temp add tempfile '/opt/oracle/oradata/ORCLCDB/ORCLPDB3/temp03.dbf' size 6000m reuse autoextend on next 500m maxsize 7000m
alter tablespace temp drop tempfile '/opt/oracle/oradata/ORCLCDB/ORCLPDB2/temp02.dbf' 
alter tablespace temp drop tempfile '/opt/oracle/oradata/ORCLCDB/ORCLPDB2/temp02.dbf' 
/
ALTER TABLESPACE UNDOTBS1 ADD DATAFILE '/opt/oracle/oradata/ORCLCDB/ORCLPDB3/undotbs01.dat' SIZE 30000M AUTOEXTEND ON NEXT 1000M;
ALTER TABLESPACE GFNDDATA ADD DATAFILE '/opt/oracle/oradata/ORCLCDB/ORCLPDB3/gfnddata_04.dat' SIZE 30000M AUTOEXTEND ON NEXT 1000M;
alter tablespace undotbs1  offline;
ALTER TABLESPACE UNDOTBS1 drop DATAFILE '/opt/oracle/oradata/ORCLCDB/ORCLPDB2/undotbs02.dat';

--prepare recreate undotblspace
--http://neeraj-dba.blogspot.ru/2011/05/how-to-drop-undo-tablespace.html
create undo tablespace UNDOTBS2 datafile  '/opt/oracle/oradata/ORCLCDB/ORCLPDB3/undotbs02.dat'  size 500M;
/
--connect with CDB via sqlplus
alter database add logfile group 1 '/opt/oracle/oradata/ORCLCDB/REDO01.LOG' size 500M;
alter database add logfile group 2 '/opt/oracle/oradata/ORCLCDB/REDO02.LOG' size 500M;
alter database add logfile group 3 '/opt/oracle/oradata/ORCLCDB/REDO03.LOG' size 500M;
/
select group#, (bytes/1024/1024) mbytes, status from v$log;
/
--переключаем группу via sqlplus
alter system switch logfile;
alter system checkpoint;
/
/*--удаляем существующие группы via sqlplus
alter database drop logfile group 4;
alter database drop logfile group 5;
alter database drop logfile group 6;
*/
--PDP3
alter tablespace temp add tempfile '/opt/oracle/oradata/ORCLCDB/ORCLPDB3/temp01.dbf' size 500m reuse autoextend on next 500m maxsize 7000m;
ALTER TABLESPACE temp TEMPFILE '/opt/oracle/oradata/ORCLCDB/ORCLPDB2/temp02.dbf' OFFLINE;
ALTER TABLESPACE temp TEMPFILE ONLINE;
ALTER DATABASE TEMPFILE '/opt/oracle/oradata/ORCLCDB/ORCLPDB2/temp01.dbf' RESIZE 300m;
alter database datafile '/opt/oracle/oradata/ORCLCDB/ORCLPDB2/undotbs02.dat' resize 30000m;
ALTER DATABASE TEMPFILE '/opt/oracle/oradata/ORCLCDB/ORCLPDB3/temp03.dbf' DROP INCLUDING DATAFILES;
--alter tablespace temp drop tempfile '/opt/oracle/oradata/ORCLCDB/ORCLPDB3/temp02.dbf' 
--create undo tablespace UNDOTBS2 datafile  '/opt/oracle/oradata/ORCLCDB/ORCLPDB3/undotbs02.dat'  size 30000M  AUTOEXTEND ON NEXT 1000M;
ALTER TABLESPACE UNDOTBS1 ADD DATAFILE '/opt/oracle/oradata/ORCLCDB/ORCLPDB3/undotbs02.dat' SIZE 30000M AUTOEXTEND ON NEXT 1000M;
