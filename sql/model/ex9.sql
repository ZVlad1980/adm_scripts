with t(id, value) as (select 0, cast(null as varchar2(4000)) from dual)
select *
from t
model
  ignore nav --null as 0
  --keep nav --(default) null as null
  dimension by (id)
  measures (value, cast(null as varchar2(4000)) result, to_number(null) num)
  (
    value[1] = '1',
    value[2] = presentv(value[0], value[0], 'V'),
    value[3] = presentnnv(value[0], value[0], 'NNV'),
    value[4] = nvl2(value[0], value[0], 'NVL2'),
    result[2] = presentv(value[1], value[1], 'V'),
    result[3] = presentnnv(value[1], value[1], 'NNV'),
    result[4] = nvl2(value[1], value[1], 'NVL2'),
    num[any] = num[-1]
  )
order by id;
