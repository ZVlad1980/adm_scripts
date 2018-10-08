--fast
select ksppinm,
       ksppstvl
from   x$ksppi  a,
       x$ksppsv b
where  a.indx = b.indx
and    substr(ksppinm, 1, 1) = '_'
order  by ksppinm
/
--detail
select a.ksppinm "Parameter",
       decode(p.isses_modifiable, 'FALSE', null, null, null, b.ksppstvl) "Session",
       c.ksppstvl "Instance",
       decode(p.isses_modifiable, 'FALSE', 'F', 'TRUE', 'T') "S",
       decode(p.issys_modifiable,
              'FALSE',
              'F',
              'TRUE',
              'T',
              'IMMEDIATE',
              'I',
              'DEFERRED',
              'D') "I",
       decode(p.isdefault, 'FALSE', 'F', 'TRUE', 'T') "D",
       a.ksppdesc "Description"
from   x$ksppi     a,
       x$ksppcv    b,
       x$ksppsv    c,
       v$parameter p
where  a.indx = b.indx
and    a.indx = c.indx
and    p.name(+) = a.ksppinm
--and    upper(a.ksppinm) like upper('%&1%')
order  by a.ksppinm;
