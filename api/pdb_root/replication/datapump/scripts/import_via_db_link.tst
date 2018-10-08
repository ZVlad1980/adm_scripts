PL/SQL Developer Test script 3.0
21
-- Created on 20.04.2018 by V.ZHURAVOV 
declare 
  -- Local variables here
  i integer;
  p_MASTER_TABLE constant varchar2(32) := 'GFDUMP_MASTER_T';
  p_handle number;
begin
  -- Test statements here
   p_handle := dbms_datapump.open('IMPORT', 'SCHEMA', 'cdm_testdb', p_master_table);
   dbms_datapump.add_File(p_handle, 'cdm_user.log',  'gfdump_log_dir', filetype => DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE);
   
   DBMS_DATAPUMP.METADATA_FILTER(handle=> p_handle, name => 'EXCLUDE_PATH_EXPR', value => '=''SCHEMA_EXPORT/USER''');
   DBMS_DATAPUMP.METADATA_FILTER(handle=> p_handle, name => 'EXCLUDE_PATH_EXPR', value => '=''TABLE_STATISTICS''');
   DBMS_DATAPUMP.METADATA_FILTER(handle=> p_handle, name => 'EXCLUDE_PATH_EXPR', value => '=''INDEX_STATISTICS''');
   DBMS_DATAPUMP.DATA_FILTER(p_handle, 'INCLUDE_ROWS', 0, NULL, NULL);
   gfdump_api.config_import_schema$(p_handle        => p_handle, p_schema        => 'CDM', p_metadata_only => true);
   dbms_datapump.metadata_transform(p_handle, 'STORAGE' , 0);
   dbms_datapump.metadata_transform(p_handle, 'DISABLE_ARCHIVE_LOGGING', 0);
   dbms_datapump.metadata_transform(p_handle, 'SEGMENT_ATTRIBUTES', 0);
   datapump_api.start_job(p_handle => p_handle);
end;
0
0
