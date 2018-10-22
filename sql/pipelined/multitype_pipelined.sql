/*
drop type employee_detail_typ;
drop type department_detail_typ;
drop type departments_typ;
drop type department_typ;
*/
create type department_typ as object(
  department_id  number
) not final;

-- Collection of supertype...
create type departments_typ as table of department_typ;

-- Customer detail subtype...
create type department_detail_typ under department_typ(
  department_name  varchar2(30),
  manager_id       number(6),
  location_id      number(4) 
) final;

-- Address detail subtype...
create type employee_detail_typ under department_typ(
  employee_id      number,
  first_name       varchar2(20),
  last_name        varchar2(25),
  hire_date        date
) final;
/
select *
from   employees
/
select *
from   departments
