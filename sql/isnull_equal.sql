with t(v1, v2) as (
  select 1, 1 from dual union all
  select 1, 2 from dual union all
  select null, 1 from dual union all
  select 1, null from dual union all
  select null, null from dual
)
select t.*,
       case
         when coalesce(nullif(t.v1, t.v2), nullif(t.v2, t.v1)) is null then 'Yes'
         else 'No'
       end nullif_,
       case
         when not SYS_OP_MAP_NONNULL(t.v1) <> SYS_OP_MAP_NONNULL(t.v2) then 'Yes'
         else 'No'
       end sus_op,
       case
         when lnnvl(t.v1 = t.v2) then 'Yes'
         else 'No'
       end equal,
       case
         when not lnnvl(t.v1 = t.v2) then 'Yes'
         else 'No'
       end equal2,
       case
         when lnnvl(t.v1 <> t.v2) then 'Yes'
         else 'No'
       end equal3,
       case
         when not lnnvl(t.v1 <> t.v2) then 'Yes'
         else 'No'
       end equal4
from   t
