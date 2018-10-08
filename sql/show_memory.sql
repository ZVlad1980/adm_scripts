select component,
       current_size / 1024 / 1024 / 1024,
       user_specified_size / 1024 / 1024 / 1024
from   v$memory_dynamic_components
where  current_size > 0
/
select name,
       value
from   v$pgastat
where  name = 'total PGA allocated'
/
SELECT component, current_size  / 1024 / 1024 / 1024 current_size, min_size, max_size
FROM v$sga_dynamic_components;
