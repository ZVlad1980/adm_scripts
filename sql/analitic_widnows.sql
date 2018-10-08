select ename,
       deptno,
       job,
       sum(sal) over(partition by deptno, job order by hiredate rows between unbounded preceding and current row) sum_sal
from   emp;
