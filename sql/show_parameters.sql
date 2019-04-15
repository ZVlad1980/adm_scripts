select *--name , display_value 
from v$parameter
where name like lower('AQ_TM_PROCESSES');
