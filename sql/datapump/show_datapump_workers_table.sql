--select sum(t.size_mb)/1024 total_size from   (
select t.process_order,
       t.base_object_schema,
       t.base_object_type,
       t.base_object_name,
       round((t.dump_length / 1024 / 1024), 3) size_mb,
       t.processing_state,
       t.processing_status,
       t.start_time,
       t.completion_time,
       (t.completion_time - t.start_time) * 86400 duration_sec
from   sys_import_full_01 t
where  1 = 1 --t.base_object_name = 'PFR_IMPORT_FILE_LINES'
and    t.base_object_schema = 'FND'
and    t.base_object_type = 'TABLE'
and    t.granules = 1
and    t.load_method is not null
order  by t.process_order
--) t
