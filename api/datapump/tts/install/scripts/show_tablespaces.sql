select df.tablespace_name                                                 "Tablespace",
       round(df.total_space / 1073741824, 3)                              "Total, G",
       round(total_used/ 1073741824, 3)                                   "Used, G",
       round((df.total_space - tu.total_used) / 1073741824, 3)            "Free, G",
       round((df.total_space - tu.total_used) / df.total_space * 100, 2)  "Pct. Free",
       tu.owners,
       df.files
from   (select ddf.tablespace_name,
               listagg(replace(ddf.file_name, '/ora1/dat/tstdb/dbs/'), ', ') within group (order by ddf.file_name) files,
               sum(ddf.bytes) total_space
        from   dba_data_files ddf
        group  by ddf.tablespace_name
        union all
        select ddf.tablespace_name, 
               listagg(replace(ddf.file_name, '/ora1/dat/tstdb/dbs/'), ', ') within group (order by ddf.file_name) files,
               sum(ddf.bytes) total_space
        from   dba_temp_files ddf
        group  by ddf.tablespace_name
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
       ) tu
where  tu.tablespace_name = df.tablespace_name;
