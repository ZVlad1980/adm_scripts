select a.tablespace_name,
       round((a.used_space * b.block_size) / 1048576, 2) as "Used space (MB)",
       round((a.tablespace_size * b.block_size) / 1048576, 2) as "Tablespace size (MB)",
       round(a.used_percent, 2) as "Used %"
from   dba_tablespace_usage_metrics a,
       dba_tablespaces b
where  a.tablespace_name = b.tablespace_name
and    b.tablespace_name = ''PDH_STG
/
--PDH_STG	1130581.69	1458135	77.54

/*
GFNDDAT2  80  42,481  37,519  46,9  ONLINE  PERMANENT GAZFOND, GAZFOND_AUD, GAZFOND_DOTNET, GAZFOND_LOGS, PDN /u01/app/oracle/oradata/weekly/WEEKLY_VBZ_2/datafile/gf2dat01.dbf, /u01/app/oracle/oradata/weekly/WEEKLY_VBZ_2/datafile/gf2dat02.dbf  LOGGING AVAILABLE
GFNDINDX  60  39,364  20,636  34,39 ONLINE  PERMANENT GAZFOND, GAZFOND_AUD, GAZFOND_DOTNET, OPSEXP, PDN /u01/app/oracle/oradata/weekly/WEEKLY_VBZ_2/datafile/gf_idx01.dbf, /u01/app/oracle/oradata/weekly/WEEKLY_VBZ_2/datafile/gf_idx02.dbf, /u01/app/oracle/oradata/weekly/WEEKLY_VBZ_2/datafile/gf_idx03.dbf, /u01/app/oracle/oradata/weekly/WEEKLY_VBZ_2/datafile/gf_idx04.dbf, /u01/app/oracle/oradata/weekly/WEEKLY_VBZ_2/datafile/gf_idx05.dbf, /u01/app/oracle/oradata/weekly/WEEKLY_VBZ_2/datafile/gf_idx06.dbf  LOGGING AVAILABLE

*/
select df.tablespace_name                                                 "Tablespace",
       round(df.total_space / 1073741824, 3)                              "Total, G",
       round(total_used/ 1073741824, 3)                                   "Used, G",
       round((df.total_space - tu.total_used) / 1073741824, 3)            "Free, G",
       round((df.total_space - tu.total_used) / df.total_space * 100, 2)  "Pct. Free",
       dt.status,
       dt.contents,
       tu.owners,
       df.files,
       dt.logging,
       df.status
from   (select ddf.tablespace_name,
               ddf.status,
               listagg(replace(ddf.file_name, '/ora1/dat/tstdb/dbs/'), ', ') within group (order by ddf.file_name) files,
               sum(ddf.bytes) total_space
        from   dba_data_files ddf
        group  by ddf.tablespace_name, ddf.status
        union all
        select ddf.tablespace_name, 
               ddf.status,
               listagg(replace(ddf.file_name, '/ora1/dat/tstdb/dbs/'), ', ') within group (order by ddf.file_name) files,
               sum(ddf.bytes) total_space
        from   dba_temp_files ddf
        group  by ddf.tablespace_name, ddf.status
       ) df,
       (select tablespace_name,
               listagg(ds.owner, ', ') within group (order by ds.owner) owners,
               sum(bytes) total_used
        from   (select ds.owner, 
                       ds.tablespace_name,
                       sum(ds.bytes)       bytes
                from   dba_segments ds
                --where  ds.owner in ('GAZFOND', 'GAZFOND_PN', 'FND', 'CDM')
                group by ds.owner, ds.tablespace_name
               ) ds
        group  by tablespace_name
       ) tu,
       dba_tablespaces dt
where  tu.tablespace_name(+) = df.tablespace_name
and    dt.tablespace_name(+) = df.tablespace_name
/
select *
from   dba_tablespace_thresholds
/
select *
from   v$log
