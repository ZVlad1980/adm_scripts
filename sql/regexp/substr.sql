with t as (
  select ' FND.GF' txt from dual union all
  select '(FND.GF' txt from dual union all
  select 'FND.GF' txt from dual union all
  select ',FND.GF' txt from dual union all
  select 'AFND.GF' txt from dual union all
  select '(AFND.GF' txt from dual 
)
select t.txt,
       regexp_substr(t.txt, '(^FND.|[^[:alnum:]]FND\.)', 1, 1) sub_txt,
       regexp_count(t.txt, '(^FND.|[^[:alnum:]]FND\.)') sub_cnt,
       case when regexp_like(t.txt, '(^FND.|[^[:alnum:]]FND\.)') then 1 end sub_exists
from   t
