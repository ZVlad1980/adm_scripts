select *
from   user_constraints uc
where  uc.OWNER = user
and    uc.CONSTRAINT_TYPE = 'R'
and    uc.R_OWNER = user
and    uc.R_CONSTRAINT_NAME in (
select uc.CONSTRAINT_NAME
from   user_constraints uc
where  1=1
and    uc.CONSTRAINT_TYPE in ('P', 'U')
and    uc.OWNER = user
and    uc.TABLE_NAME in ('CONTRACT_VERSIONS', 'DEPARTMENTS', 'OFFICE_TEMPLATES')
)
