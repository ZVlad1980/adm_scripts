--http://www.andreydba.com/oracle/auditing-monitoring/actions-in-sys-aud
select *
from   user_audit_trail t
where  1=1
and    t.action not in (0,2,3,6,7,26, 27,44,45,46,47,48,50,100,101,102, 103,116)
