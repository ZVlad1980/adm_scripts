select df.tablespace_name "Tablespace",
       df.file_name "File Name",
       df.file_id "File ID",
       df.totalspace "Total MB",
       totalusedspace "Used MB",
       (df.totalspace - tu.totalusedspace) "Free MB",
       round(100 * ((df.totalspace - tu.totalusedspace) / df.totalspace)) "Pct. Free"
from   (select file_name,
               file_id,
               tablespace_name,
               round(sum(bytes) / 1048576) totalspace
        from   dba_data_files
        group  by file_name,
                  file_id,
                  tablespace_name
        union all
        select file_name,
               file_id,
               tablespace_name,
               round(sum(bytes) / 1048576) totalspace
        from   dba_temp_files
        group  by file_name,
                  file_id,
                  tablespace_name) df,
       (select round(sum(bytes) / (1024 * 1024)) totalusedspace,
               tablespace_name
        from   dba_segments ds
        group  by tablespace_name) tu
where  df.tablespace_name = tu.tablespace_name(+);
/
