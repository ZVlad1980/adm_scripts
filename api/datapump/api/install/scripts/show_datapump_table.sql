--create table DP_CDM_COPY as
select t.process_order,
       t.base_object_schema,
       t.base_object_type,
       t.base_object_name,
       round((t.dump_length / 1024 / 1024), 3) size_mb,
       t.processing_state,
       t.processing_status,
       t.start_time,
       t.completion_time,
       (t.completion_time - t.start_time) * 86400 duration_sec,
       t.load_method --*/
from   DP_FND6 t
where  1 = 1 --
--and    t.base_object_name like '%CASH%'
and    t.base_object_schema = 'FND'
and    t.object_type = 'TABLE_DATA'
--and    t.granules = 1
--and    t.object_type_path like '%GRANT%'
--and    t.object_type = 'OBJECT_GRANT'
--and    t.load_method is not null
order  by t.process_order
/
--drop table DP_CDM6
