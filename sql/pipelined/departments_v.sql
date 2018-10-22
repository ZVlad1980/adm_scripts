create or replace view departments_v as
  select d.department_id,
         d.department_name,
         d.manager_id,
         d.location_id,
         e.employee_id,
         e.first_name,
         e.last_name,
         e.hire_date
  from   departments d,
         employees   e
  where  e.department_id = e.department_id
/
