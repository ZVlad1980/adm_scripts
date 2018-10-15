--The following statement locks rows in the employees table with purchasing clerks located in Oxford, 
--  which has location_id 2500, and locks rows in the departments table with departments in Oxford that have purchasing clerks:
SELECT e.employee_id, e.salary, e.commission_pct
   FROM employees e, departments d
   WHERE job_id = 'SA_REP'
   AND e.department_id = d.department_id
   AND location_id = 2500
   ORDER BY e.employee_id
   FOR UPDATE
;
--The following statement locks only those rows in the employees table with purchasing clerks located in Oxford. 
--  No rows are locked in the departments table:
SELECT e.employee_id, e.salary, e.commission_pct
   FROM employees e JOIN departments d
   USING (department_id)
   WHERE job_id = 'SA_REP'
   AND location_id = 2500
   ORDER BY e.employee_id
   FOR UPDATE OF e.salary
;
