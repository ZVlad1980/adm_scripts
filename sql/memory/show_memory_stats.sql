select s.NAME, value /1024/1024/1024 value,
       s.CON_ID
from v$sga s;
/
select name, 
       case unit
         when 'bytes' then round(value /1024/1024/1024, 6)
         else value
       end value, 
       case p.unit
         when 'bytes' then 'Gb'
         else p.unit
       end UNIT,
       p.CON_ID
from   v$pgastat p
order by case when name='maximum PGA allocated' then 0 else 1 end, name
