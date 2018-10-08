select occupant_desc, space_usage_kbytes
from v$sysaux_occupants
where space_usage_kbytes > 0 
order by space_usage_kbytes desc;
/
select count(*) from unified_audit_trail
/
select a.unified_audit_policies,
       a.action_name,
       count(*) cnt
from   unified_audit_trail a
group by a.unified_audit_policies,
       a.action_name
/
select *
from   unified_audit_trail a
where  a.action_name = 'AUDIT'
