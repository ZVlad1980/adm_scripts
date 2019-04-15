with t(value) as (select column_value from table(sys.odcivarchar2list('A','B','C','D','E')))
select *
from   t
model
  ignore nav
  dimension by (row_number() over (order by value) id)
  measures (value, cast(null as varchar2(4000)) result, count(*) over () num)
  (
    result[mod(id, 2) = 1] = listagg(value, ', ') within group (order by id) over (),
    num[mod(id, 2) = 1] = count(*) over (order by id desc)
    /* the same:
    result[mod(id, 2) = 1] = listagg(value, ', ') within group (order by null)[mod(id, 2) = 1],
    num[mod(id, 2) = 1] = count(*)[mod(id, 2) = 1 and id >= cv(id)]
    */
  )
order by id;
