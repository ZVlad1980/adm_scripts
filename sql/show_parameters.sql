select *--name , display_value 
from v$spparameter
where name like '%ga%';
/
select * from v$database;
