--https://livesql.oracle.com/apex/livesql/file/content_C1W23DSC7WZM6WY23PBAJZI2W.html

DECLARE  
   TYPE strings_t IS TABLE OF VARCHAR2 (200);
   type t_users is table of all_users%rowtype;
   l_cv             sys_refcursor;  
   l_values         strings_t     := strings_t ('PDH_STG');  
   l_names          t_users;
  
   function employee_names(
     where_in          in varchar2,
     bind_variables_in in strings_t,
     placeholders_in   in strings_t
   ) return sys_refcursor is
     l_dyn_cursor number;
     l_cv         sys_refcursor;
     l_dummy      pls_integer;
   begin
     /* Parse the retrieval of last names after appending the WHERE clause.  
     
     NOTE: if you ever write code like this yourself, you MUST take steps  
     to minimize the risk of SQL injecction.   
     */
     l_dyn_cursor := dbms_sql.open_cursor;
     dbms_sql.parse(l_dyn_cursor,
                    'SELECT * FROM all_users WHERE ' || where_in,
                    dbms_sql.native);
   
     /*  
        Bind each of the variables to the named placeholders;  
        You cannot use EXECUTE IMMEDIATE for this step if you have  
        a variable number of placeholders!  
     */
     for indx in 1 .. placeholders_in.count loop
       dbms_sql.bind_variable(l_dyn_cursor,
                              placeholders_in(indx),
                              bind_variables_in(indx));
     end loop;
   
     /*  
     Execute the query now that all variables are bound.  
     */
     l_dummy := dbms_sql.execute(l_dyn_cursor);
     /*  
     Now it's time to convert to a cursor variable so that the front end  
     program or another PL/SQL program can easily fetch the values.  
     */
     l_cv := dbms_sql.to_refcursor(l_dyn_cursor);
     /*  
     Do not close with DBMS_SQL; you can ONLY manipulate the cursor  
     through the cursor variable at this point.  
     DBMS_SQL.close_cursor (l_dyn_cursor);  
     */
     return l_cv;
   end employee_names;
   
BEGIN  
   l_cv :=  
        employee_names ('username = :username', l_values, l_placeholders);  
  
   FETCH l_cv  
   BULK COLLECT INTO l_names;  
  
   FOR indx IN 1 .. l_names.COUNT  
   LOOP  
      DBMS_OUTPUT.put_line (l_names(indx).user_id || ' - ' || l_names(indx).username);  
   END LOOP;  
  
   CLOSE l_cv;  
END; 
