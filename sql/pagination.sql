//https://oracle-base.com/articles/12c/row-limiting-clause-for-top-n-queries-12cr1

select * 
from   DV_SR_LSPV_DOCS_T t
order by date_op, id
offset 5 rows fetch next 10 rows only
/
select * 
from   DV_SR_LSPV_DOCS_T t
order by date_op, id
offset 50 rows fetch next 150 rows only
/

fetch first rows only
/
create table f2ndfl_test_zh as select level id, to_char(level) code, 0 batch_num from dual connect by level <= 100
/
update (select z.id, z.batch_num from f2ndfl_test_zh z where z.id in(select zz.id from f2ndfl_test_zh zz order by zz.id offset 20 rows fetch next 20 rows only)) z
set    z.batch_num = 2
/
select *
from   f2ndfl_test_zh
