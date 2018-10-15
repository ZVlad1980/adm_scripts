/*
  The oe.orders table contains information about when an order was placed (order_date), how it was place (order_mode), 
    and the total amount of the order (order_total), as well as other information. 
  The following example shows how to use the PIVOT clause to pivot order_mode values into columns, 
    aggregating order_total data in the process, to get yearly totals by order mode:
*/
CREATE TABLE pivot_table AS
  SELECT *
  FROM   (
           SELECT EXTRACT(YEAR FROM order_date) year, 
                  order_mode, 
                  order_total 
           FROM orders
         )
    PIVOT
      (SUM(order_total) FOR order_mode IN ('direct' AS Store, 'online' AS Internet));

SELECT * FROM pivot_table ORDER BY year
;
SELECT * FROM pivot_table
  UNPIVOT (yearly_total FOR order_mode IN (store AS 'direct',
           internet AS 'online'))
  ORDER BY year, order_mode
;
SELECT * FROM pivot_table
  UNPIVOT INCLUDE NULLS 
    (yearly_total FOR order_mode IN (store AS 'direct', internet AS 'online'))
  ORDER BY year, order_mode
;
drop TABLE pivot_table;
