create or replace package pipelined_api is

  -- Author  : V.ZHURAVOV
  -- Created : 19.10.2018 15:04:54
  -- Purpose : 
  
  -- Public type declarations
  function departments_pipe(
   p_source     in sys_refcursor, --customer_staging_rct,
   p_limit_size in pls_integer default 100
 ) return departments_typ
   pipelined
   --parallel_enable(partition p_source by hash(customer_id)) 
   --order p_source by(customer_id, address_id)
   ;

end pipelined_api;
/
create or replace package body pipelined_api is

 function departments_pipe(
   p_source     in sys_refcursor, --customer_staging_rct,
   p_limit_size in pls_integer default 100
 ) return departments_typ
   pipelined
   --parallel_enable(partition p_source by hash(customer_id)) 
   --order p_source by(customer_id, address_id)
 is
   type t_departments is table of departments_v%rowtype;
   
   l_chunk          t_departments;
   l_department_id  departments.department_id%type := -1;
 begin
   loop
     fetch p_source bulk collect
       into l_chunk limit p_limit_size;
     exit when l_chunk.count = 0;
   
     for i in 1..l_chunk.count loop
     
       /* Only pipe the first instance of the customer details... */
       if l_chunk(i).department_id <> l_department_id then
         pipe row(department_detail_typ(
           l_chunk(i).department_id   ,
           l_chunk(i).department_name ,
           l_chunk(i).manager_id      ,
           l_chunk(i).location_id
         ));
       end if;
     
       pipe row(employee_detail_typ(
         l_chunk(i).department_id ,
         l_chunk(i).employee_id   ,
         l_chunk(i).first_name    ,
         l_chunk(i).last_name     ,
         l_chunk(i).hire_date
       ));
     
       /* Save customer ID for "control break" logic... */
       l_department_id := l_chunk(i).department_id;
     
     end loop;
   end loop;
   
   close p_source;
   
   return;
 end departments_pipe;
 
end pipelined_api;
/
