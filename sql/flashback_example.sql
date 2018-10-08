select *
from   err$_people
AS OF TIMESTAMP (SYSDATE-1/288)
where  nvl(ora_err_tag$, 'UPDATED') <> 'UPDATED' 
