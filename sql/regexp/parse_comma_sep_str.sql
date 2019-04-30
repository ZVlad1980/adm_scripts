with t as (
  select 'ab, cd' txt from   dual
)
select t.txt,
       level lvl,
       trim(regexp_substr(t.txt, '[^,]+', 1, level)) value,
       regexp_count(t.txt, '[^,]+') cnt_values
from   t
connect by level <= regexp_count(t.txt, '[^,]+')
