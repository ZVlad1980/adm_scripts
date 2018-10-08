with w_path as (
select substr(ddf.file_name, 1, instr(ddf.file_name, 'dbs/', -1) + 3) files_path
from   dba_data_files ddf
where  ddf.tablespace_name = 'SYSTEM'
)
select 'scp oracle@10.1.1.108:' || files_path || 'arh* /u01/app/oracle/backup/aix_files/' scp_cmd from w_path union all
select 'scp oracle@10.1.1.108:' || files_path || 'ctx* /u01/app/oracle/backup/aix_files/' from w_path union all
select 'scp oracle@10.1.1.108:' || files_path || 'dwh* /u01/app/oracle/backup/aix_files/' from w_path union all
select 'scp oracle@10.1.1.108:' || files_path || 'inf* /u01/app/oracle/backup/aix_files/' from w_path union all
select 'scp oracle@10.1.1.108:' || files_path || 'mdm* /u01/app/oracle/backup/aix_files/' from w_path union all
select 'scp oracle@10.1.1.108:' || files_path || 'ops* /u01/app/oracle/backup/aix_files/' from w_path union all
select 'scp oracle@10.1.1.108:' || files_path || 'web* /u01/app/oracle/backup/aix_files/' from w_path union all
select 'scp oracle@10.1.1.108:' || files_path || 'f* /u01/app/oracle/backup/aix_files/' from w_path union all
select 'scp oracle@10.1.1.108:' || files_path || 'g* /u01/app/oracle/backup/aix_files/' from w_path union all
select 'scp oracle@10.1.1.108:' || files_path || 'smppdat01* /u01/app/oracle/backup/aix_files/' from w_path union all
select 'scp oracle@10.1.1.108:' || files_path || 'usr* /u01/app/oracle/backup/aix_files/' from w_path union all
select 'scp oracle@10.1.1.108:' || files_path || 'etl* /u01/app/oracle/backup/aix_files/' from w_path
