PL/SQL Developer Test script 3.0
234
declare
  ind          number; -- Loop index
  spos NUMBER;             -- String starting position
  slen NUMBER;             -- String length for output
  h1           number; -- Data Pump job handle
  percent_done number; -- Percentage of job complete
  job_state    varchar2(30); -- To keep track of job state
  le           ku$_logentry; -- For WIP and error messages
  js           ku$_jobstatus; -- The job status from get_status
  jd           ku$_jobdesc; -- The job description from get_status
  sts          ku$_status; -- The status object returned by get_status
  --
  start_time   int;
  --
  cursor c_load_tables is
    select e.table_name
    from   DP_GF_EXCLUDE e;
  /*
    select t.base_object_name
    from   DP_CDM_COPY t
    where  1 = 1 --t.base_object_name = 'PFR_IMPORT_FILE_LINES'
    and    t.base_object_schema = 'CDM'
    and    t.base_object_type = 'TABLE'
--    and    t.granules = 1
    --and    t.load_method is not null
    order  by t.process_order;*/
  --
  procedure show_error_info_ is
  begin
    dbms_output.put_line('Exception in Data Pump job ' || sqlcode);
    dbms_datapump.get_status(h1,dbms_datapump.ku$_status_job_error,0,
                             job_state,sts);
    if (bitand(sts.mask,dbms_datapump.ku$_status_job_error) != 0)
    then
      le := sts.error;
      if le is not null
      then
        ind := le.FIRST;
        while ind is not null loop
          spos := 1;
          slen := length(le(ind).LogText);
          if slen > 255
          then
            slen := 255;
          end if;
          while slen > 0 loop
            dbms_output.put_line(substr(le(ind).LogText,spos,slen));
            spos := spos + 255;
            slen := length(le(ind).LogText) + 1 - spos;
          end loop;
          ind := le.NEXT(ind);
        end loop;
      end if;
    end if;
  end;
  --
  procedure show_state_job_ is
  begin
    percent_done := 0;
    job_state    := 'UNDEFINED';
    while (job_state != 'COMPLETED') and (job_state != 'STOPPED') loop
      dbms_datapump.get_status(h1,
                               dbms_datapump.ku$_status_job_error +
                               dbms_datapump.ku$_status_job_status +
                               dbms_datapump.ku$_status_wip,
                               -1,
                               job_state,
                               sts);
      js := sts.job_status;
    
      -- If the percentage done changed, display the new value.
    
      if js.percent_done != percent_done then
        dbms_output.put_line('*** Job percent done = ' ||
                             to_char(js.percent_done));
        percent_done := js.percent_done;
      end if;
    
      -- If any work-in-progress (WIP) or Error messages were received for the job,
      -- display them.
    
      if (bitand(sts.mask, dbms_datapump.ku$_status_wip) != 0) then
        le := sts.wip;
      else
        if (bitand(sts.mask, dbms_datapump.ku$_status_job_error) != 0) then
          le := sts.error;
        else
          le := null;
        end if;
      end if;
      if le is not null then
        ind := le.first;
        while ind is not null loop
          dbms_output.put_line(le(ind).logtext);
          ind := le.next(ind);
        end loop;
      end if;
    end loop;
  end;
begin
  start_time := dbms_utility.get_cpu_time;
--dbms_session.reset_package; return;
  -- Create a (user-named) Data Pump job to do a "full" import (everything
  -- in the dump file without filtering).
 -- h1 := dbms_datapump.open('IMPORT', 'SCHEMA', null, 'DP_CDM');
  begin
    h1 := dbms_datapump.attach('DP_FND6', user);
    dbms_output.put_line('Restart exists job');
  exception
    when dbms_datapump.no_such_job then
      dbms_output.put_line('Open new JOB');
      h1 := dbms_datapump.open('IMPORT', 'SCHEMA', null, 'DP_FND6');
      -- Specify the single dump file for the job (using the handle just returned)
      -- and directory object, which must already be defined and accessible
      -- to the user running this procedure. This is the dump file created by
      -- the export operation in the first example.
      dbms_datapump.set_parallel(handle => h1, degree => 2);
      --
      --dbms_datapump.add_file(h1, 'cdm180404%U.dpdmp', upper('dump_dir_cdm'), filetype => DBMS_DATAPUMP.KU$_FILE_TYPE_DUMP_FILE);
      dbms_datapump.add_file(h1, 'fnd180404%U.dpdmp', upper('dump_dir_fnd'), filetype => DBMS_DATAPUMP.KU$_FILE_TYPE_DUMP_FILE);
      --dbms_datapump.add_file(h1, 'fnd180404%U.dpdmp', upper('dump_dir_fnd'), filetype => DBMS_DATAPUMP.KU$_FILE_TYPE_DUMP_FILE);
      Dbms_DataPump.Add_File(handle => h1, filename => 'import_fnd_log', directory => upper('dump_dir_fnd'), filetype => DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE);
      --
      if 1=1 then
        --DBMS_DATAPUMP.METADATA_FILTER(handle=> h1, name => 'EXCLUDE_PATH_EXPR', value => '=''INDEX''');
        --DBMS_DATAPUMP.METADATA_FILTER(handle=> h1, name => 'EXCLUDE_PATH_EXPR', value => '=''TABLE/INDEX''');
        --DBMS_DATAPUMP.METADATA_FILTER(handle=> h1, name => 'EXCLUDE_PATH_EXPR', value => '=''REF_CONSTRAINT''');
        --DBMS_DATAPUMP.METADATA_FILTER(handle=> h1, name => 'EXCLUDE_PATH_EXPR', value => '=''TABLE/CONSTRAINT''');
        --DBMS_DATAPUMP.METADATA_FILTER(handle=> h1, name => 'EXCLUDE_PATH_EXPR', value => '=''TABLE/CONSTRAINT/REF_CONSTRAINT''');
        --DBMS_DATAPUMP.METADATA_FILTER(handle=> h1, name => 'EXCLUDE_PATH_EXPR', value => '=''OBJECT_GRANT''');
        --DBMS_DATAPUMP.METADATA_FILTER(handle=> h1, name => 'EXCLUDE_PATH_EXPR', value => '=''TRIGGER''');
        null;
      else
        --DBMS_DATAPUMP.METADATA_FILTER(handle=> h1, name => 'INCLUDE_PATH_EXPR', value => '=''REF_CONSTRAINT''');
        DBMS_DATAPUMP.METADATA_FILTER(handle=> h1, name => 'INCLUDE_PATH_EXPR', value => '=''SCHEMA_EXPORT/USER''');
        --DBMS_DATAPUMP.METADATA_FILTER(handle=> h1, name => 'INCLUDE_PATH_EXPR', value => '=''OBJECT_GRANT''');
        --
      end if;
      DBMS_DATAPUMP.METADATA_FILTER(handle=> h1, name => 'EXCLUDE_PATH_EXPR', value => '=''TABLE_STATISTICS''');
      DBMS_DATAPUMP.METADATA_FILTER(handle=> h1, name => 'EXCLUDE_PATH_EXPR', value => '=''INDEX_STATISTICS''');
      --DBMS_DATAPUMP.SET_PARAMETER (h1, 'INCLUDE_METADATA', 0); --DATA_ONLY!!!!
      --
      dbms_datapump.set_parameter(h1, 'KEEP_MASTER', 1);
      if 0=1 then
        for t in c_load_tables loop
          /*if t.base_object_name like 'TRANSFORM%' then
            dbms_output.put_line('set INCLUDE 0 for ' || t.base_object_name);
            DBMS_DATAPUMP.DATA_FILTER(h1,'INCLUDE_ROWS', 0, t.base_object_name, 'CDM'); --DATA_ONLY exclude
          end if;--*/
          dbms_output.put_line('set INCLUDE 0 for ' || t.table_name);
            DBMS_DATAPUMP.DATA_FILTER(h1,'INCLUDE_ROWS', 0, t.table_name, 'GAZFOND'); --DATA_ONLY exclude
        end loop;--*/
      else
        DBMS_DATAPUMP.DATA_FILTER(h1,'INCLUDE_ROWS',0,NULL,NULL); --metadataonly
      end if;
      --
      dbms_datapump.metadata_remap(h1, 'REMAP_TABLESPACE', 'UFNDINDX', 'GFNDDATA');
      dbms_datapump.metadata_remap(h1, 'REMAP_TABLESPACE', 'UFNDDATA', 'GFNDDATA');
      dbms_datapump.metadata_remap(h1, 'REMAP_TABLESPACE', 'GFPNINDX', 'GFNDDATA');
      dbms_datapump.metadata_remap(h1, 'REMAP_TABLESPACE', 'GFPNDATA', 'GFNDDATA');
      dbms_datapump.metadata_remap(h1, 'REMAP_TABLESPACE', 'GFNDINDX', 'GFNDDATA');
      dbms_datapump.metadata_remap(h1, 'REMAP_TABLESPACE', 'GFNDDAT2', 'GFNDDATA');
      dbms_datapump.metadata_remap(h1, 'REMAP_TABLESPACE', 'FONDDATA', 'GFNDDATA');
      
      
      --
      --KEEP_MASTER
      --
      --DBMS_DATAPUMP.METADATA_FILTER (HANDLE => H1, NAME => 'SCHEMA_EXPR', VALUE => '= ''CDM'''); 
      --DBMS_DATAPUMP.METADATA_FILTER(HANDLE => H1, NAME => 'NAME_EXPR', VALUE =>'IN(''CONTRACT_TYPES'')', OBJECT_TYPE => 'TABLE');
    
      /*
      DBMS_DATAPUMP.DATA_FILTER(handle => h1,Name => 'SUBQUERY',value => 'where employee_id < 160', table_name => 'EMPLOYEES'); 

      */
      --
      dbms_datapump.metadata_transform ( h1, 'STORAGE' , 0) ;
      dbms_datapump.metadata_transform(
        handle      => h1,
        name        => 'disable_archive_logging',
        value       => 0
      );
      dbms_datapump.metadata_transform(h1, 'SEGMENT_ATTRIBUTES', 0);
  end;
  dbms_output.put_line('H1: ' || h1);
  --dbms_datapump.detach(h1);
  --return;
  --
  dbms_datapump.start_job(
    handle       => h1,    abort_step   => -1
  );
  --
  show_state_job_;
  --
  dbms_output.put_line('Job has completed');
  dbms_output.put_line('Final job state = ' || job_state);
  dbms_output.put_line('Duration: ' || to_char(dbms_utility.get_cpu_time - start_time) || ' ms');
  dbms_datapump.detach(h1);
exception
  when others then
    dbms_output.put_line('Duration: ' || to_char(dbms_utility.get_cpu_time - start_time) || ' ms');
    show_error_info_;
    if h1 is not null then
      dbms_datapump.detach(h1);
    end if;
end;
/*
return;
  -- A metadata remap will map all schema objects from HR to BLAKE.

  
  -- If a table already exists in the destination schema, skip it (leave
  -- the preexisting table alone). This is the default, but it does not hurt
  -- to specify it explicitly.

  --dbms_datapump.set_parameter(h1, 'TABLE_EXISTS_ACTION', 'SKIP');
  

  -- Start the job. An exception is returned if something is not set up properly.
return;
  dbms_datapump.start_job(h1);

  -- The import job should now be running. In the following loop, the job is 
  -- monitored until it completes. In the meantime, progress information is 
  -- displayed. Note: this is identical to the export example.

  

  -- Indicate that the job finished and gracefully detach from it. 

  
  dbms_datapump.detach(h1);
end;
  --*/
0
0
