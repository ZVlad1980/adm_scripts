select case
         when value(d) is of type (department_detail_typ) then
           'DEPT'
         else 'EMP'
       end row_type,
       treat(value(d) as department_detail_typ) obj_dept,
       treat(value(d) as employee_detail_typ) obj_empl
from   table(pipelined_api.departments_pipe(cursor(
         select * from departments_v
       ))) d
where  rownum < 15
/
select value(d) obj from table(pipelined_api.departments_pipe(cursor(select * from departments_v))) d where rownum < 15
/
