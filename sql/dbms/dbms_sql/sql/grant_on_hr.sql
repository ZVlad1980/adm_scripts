select *
from   employees
/
select *
from   departments
/
select *
from   locations
/
grant select on employees to node;
grant select on departments to node;
grant select on locations to node;
