select *
from   v$nls_parameters

/
select * from
(select 'SESSION' SCOPE,nsp.* from nls_session_parameters nsp
union
select 'DATABASE' SCOPE,ndp.* from nls_database_parameters ndp
union
select 'INSTANCE' SCOPE,nip.* from nls_instance_parameters nip
) a
pivot  (LISTAGG(VALUE) WITHIN GROUP (ORDER BY SCOPE)
FOR SCOPE
in ('SESSION' as "SESSION",'DATABASE' as DATABASE,'INSTANCE' as INSTANCE));
