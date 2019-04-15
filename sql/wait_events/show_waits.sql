--https://docs.oracle.com/database/121/REFRN/GUID-03BFEEFB-1020-4F3F-8CF8-A23E7026684B.htm#REFRN101
select name,
       wait_class
from   v$event_name
order  by name;
/
select *
from   V$SESSION_WAIT
/
select *
from   V$SYSTEM_EVENT
/
--V$SESSION_EVENT is similar to V$SYSTEM_EVENT, but displays all waits for each session.
select *
from   V$SESSION_EVENT
