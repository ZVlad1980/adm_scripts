with t(id, value) as (select trunc(rownum/2), rownum from dual connect by level <= 3)
select *
from t
model
  unique single reference  --less required unique dimensions
  --unique dimension --(its default)
  dimension by (id)
  measures (value, 0 result)
  (result[0] = 111)
order by id;
