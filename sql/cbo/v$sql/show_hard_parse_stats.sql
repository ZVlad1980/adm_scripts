ALTER SYSTEM FLUSH SHARED_POOL;
select s.name,
       m.value
from   v$statname s,
       v$mystat   m
where  s.statistic# = m.statistic#
and    s.name like '%(hard%'
;
/*
NAME                    VALUE
------------------ ----------
parse count (hard)         48
*/
SELECT COUNT(*) FROM DBA_JOBS
;
select s.name,
       m.value
from   v$statname s,
       v$mystat   m
where  s.statistic# = m.statistic#
and    s.name like '%(hard%'
;
/*
NAME                    VALUE
------------------ ----------
parse count (hard)         49
*/
SELECT COUNT(*) FROM DBA_JOBS
;
select s.name,
       m.value
from   v$statname s,
       v$mystat   m
where  s.statistic# = m.statistic#
and    s.name like '%(hard%'
;
/*
NAME                    VALUE
------------------ ----------
parse count (hard)         49
*/
