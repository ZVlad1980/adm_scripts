with t as (
  select '31.12.2016  27.12.2016  0 88800 -11544' str from dual
)
select t.str,
       regexp_substr(t.str, '[^ ]+', 1, 1) pos_2
from   t
