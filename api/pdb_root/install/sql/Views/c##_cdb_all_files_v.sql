create or replace view cdb_all_files_v as
  with w_all_files as (
    select df.con_id,
           df.ts#,
           'DATA' file_type,
           df.file#,
           df.name,
           df.rfile#,
           df.status,
           round(df.bytes / 1024 / 1024) size_mb
    from   v_$datafile df
    union all
    select tf.con_id,
           tf.ts#,
           'TEMP' file_type,
           tf.file#,
           tf.name,
           tf.rfile#,
           tf.status,
           round(tf.bytes / 1024 / 1024) size_mb
    from   v_$tempfile tf
  )
  select p.name                                                         pdb_name,
         f.file#                                                        file_id,
         substr(f.name, instr(f.name, '/', -1) + 1)                     file_name,
         f.file_type                                                    file_type,
         ts.name                                                        tablespace_name,
         row_number()over(partition by f.con_id, f.ts# order by f.name) file_num,
         substr(f.name, 1, instr(f.name, '/', -1, 2) - 1)               pdb_path,
         substr(f.name, 1, instr(f.name, '/', -1) - 1)                  file_path,
         f.name                                                         full_file_name,
         f.status,
         f.size_mb
  from   w_all_files     f,
         v$pdbs          p,
         v_$tablespace   ts
  where  1=1
  and    p.CON_ID = f.con_id
  and    ts.TS# = f.ts#
  and    ts.CON_ID = f.con_id
/
/*
  select p.name pdb_name,
         df.file_id,
         substr(df.file_name, instr(df.file_name, '/', -1) + 1)       file_name,
         df.file_type,
         df.tablespace_name,
         row_number()over(partition by p.con_id, df.tablespace_name order by df.file_name) file_num,
         substr(df.file_name, 1, instr(df.file_name, '/', -1, 2) - 1) pdb_path,
         substr(df.file_name, 1, instr(df.file_name, '/', -1) - 1)    file_path,
         df.file_name full_file_name,
         df.bytes,
         df.blocks,
         df.status,
         df.relative_fno,
         df.autoextensible,
         df.maxbytes,
         df.maxblocks,
         df.increment_by,
         df.user_bytes,
         df.user_blocks,
         df.online_status,
         p.con_id,
         p.open_mode,
         p.dbid,
         p.guid
  from   v$pdbs         p,
         (select df.con_id,
                 'DATA' file_type,
                 df.file_name,
                 df.file_id,
                 df.tablespace_name,
                 df.bytes,
                 df.blocks,
                 df.status,
                 df.relative_fno,
                 df.autoextensible,
                 df.maxbytes,
                 df.maxblocks,
                 df.increment_by,
                 df.user_bytes,
                 df.user_blocks,
                 df.online_status
         	from   cdb_data_files df
          union all
          select df.con_id,
                 'TEMP' file_type,
                 df.file_name,
                 df.file_id,
                 df.tablespace_name,
                 df.bytes,
                 df.blocks,
                 df.status,
                 df.relative_fno,
                 df.autoextensible,
                 df.maxbytes,
                 df.maxblocks,
                 df.increment_by,
                 df.user_bytes,
                 df.user_blocks,
                 null online_status
         	from   cdb_temp_files df
         ) df
  where  df.con_id = p.con_id
*/
