SELECT salary FROM employees
   WHERE last_name = 'Chung'
;
UPDATE employees SET salary = 4000
   WHERE last_name = 'Chung'
;
SELECT salary FROM employees
   WHERE last_name = 'Chung'
;
SELECT salary FROM employees
   AS OF TIMESTAMP (SYSTIMESTAMP - INTERVAL '1' MINUTE)
   WHERE last_name = 'Chung'
;
--interval
SELECT salary FROM employees
  VERSIONS BETWEEN TIMESTAMP
    SYSTIMESTAMP - INTERVAL '10' MINUTE AND
    SYSTIMESTAMP - INTERVAL '1' MINUTE
  WHERE last_name = 'Chung'
;
--restore
UPDATE employees SET salary =      
   (SELECT salary FROM employees
   AS OF TIMESTAMP (SYSTIMESTAMP - INTERVAL '2' MINUTE)
   WHERE last_name = 'Chung')
   WHERE last_name = 'Chung'
;
SELECT salary FROM employees
   WHERE last_name = 'Chung'
;
