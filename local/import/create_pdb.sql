COLUMN PDB_NAME FORMAT A15
 
SELECT PDB_ID, PDB_NAME, STATUS FROM DBA_PDBS ORDER BY PDB_ID;

Клонирование PDB

alter pluggable database orclpdb1 close immediate;
alter pluggable database orclpdb1 open read only;
create pluggable database orclpdb2 from orclpdb1 file_name_convert=('PDB1','PDB2');
alter pluggable database orclpdb1 close immediate;
alter pluggable database orclpdb2 open;

alter pluggable database orclpdb2 close immediate;
alter pluggable database orclpdb2 open read only;
create pluggable database orclpdb3 from orclpdb2 snapshot copy file_name_convert=('PDB2','PDB3') tempfile reuse;
alter pluggable database orclpdb3 open;
drop pluggable database orclpdb3 including datafiles;

--сохранение состояния (для автооткрытия pdb при подьеме системы)
alter pluggable database orclpdb2 save state; 
alter pluggable database all save state;
alter pluggable database all except pdb_name1, pdb_name2 save state;

alter pluggable database orclpdb2 close immediate;
alter pluggable database orclpdb2 open read only;
--pdp3
alter pluggable database orclpdb1 open read only;
create pluggable database orclpdb3 from orclpdb2 file_name_convert=('PDB2','PDB3');
alter pluggable database orclpdb1 close immediate;
alter pluggable database orclpdb3 open;
alter pluggable database all save state;
--
alter pluggable database orclpdb3 close immediate;
drop pluggable database orclpdb2 including datafiles;

Настройка для data pump:
увеличиваем редо и ундо логи
D:\projects\localdb\datapump_dir\sql\alter_log_and_undo.sql

для импорта тока данных - гасим рефконстрейны
D:\projects\localdb\datapump_dir\sql\alter_table_contraints.sql




via dblink:

export ORACLE_SID=ORCLCDB
sqlplus / as sysdba

create public database link BSV connect to system identified by system using '10.1.5.16:1521/ORCLCDB';
create pluggable database ORCLPDB10 from ORCLPDB2@BSV file_name_convert=('PDB2/','PDB10/');
alter pluggable database all open;


удаление PDB
alter pluggable database orclpdb2 close immediate;
drop pluggable database orclpdb2 including datafiles;
