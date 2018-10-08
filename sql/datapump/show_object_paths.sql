select */*object_path,
       comments*/
from   schema_export_objects
where  object_path like '%GRANT%'
--and    object_path not like '%/%';
