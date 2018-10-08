create or replace view v_my_stats
as
select
  /*+
    first_rows
    ordered
  */
  ms.ksusenum   sid,
  sn.indx     statistic#,
  sn.ksusdnam   name,
  sn.ksusdcls   class,
  ms.ksusestv   value
from
  x$ksumysta  ms,
  x$ksusd   sn
where
  ms.inst_id = sys_context('userenv','instance')
and bitand(ms.ksspaflg,1)!=0 
and bitand(ms.ksuseflg,1)!=0 
and sn.inst_id = sys_context('userenv','instance')
and sn.indx = ms.ksusestn
;
drop public synonym v$my_stats;
create public synonym v$my_stats for v_my_stats;
grant select on v$my_stats to public;
