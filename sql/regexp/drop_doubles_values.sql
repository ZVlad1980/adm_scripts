with t as
 (select '170, 171, 172' txt
  from   dual
  union all
  select '170, 171, 171, 172'
  from   dual)
select txt,
       regexp_replace(txt, '([^,]+)(,\1)+', '\1') result
from   t;
