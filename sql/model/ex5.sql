--Order the processed of rules
with t as (select rownum id from dual connect by level <= 3)
select *
from   t
model
  dimension by (id)
  measures (0 t1, 0 x, 0 t2)
  --rules automatic order
  rules sequential order
  (
  t1[id] = x[cv(id)-1],
  x[id] = cv(id),
  t2[id] = x[cv(id)-1]
  --t1[id] = x[cv(id)] + t2[cv(id)]
  )
order by id;
