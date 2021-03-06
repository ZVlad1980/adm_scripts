CREATE TABLE inventory (time_id    DATE,
                        product    VARCHAR2(10),
                        quantity   NUMBER);

INSERT INTO inventory VALUES (TO_DATE('01/04/01', 'DD/MM/YY'), 'bottle', 10);
INSERT INTO inventory VALUES (TO_DATE('06/04/01', 'DD/MM/YY'), 'bottle', 10);
INSERT INTO inventory VALUES (TO_DATE('01/04/01', 'DD/MM/YY'), 'can', 10);
INSERT INTO inventory VALUES (TO_DATE('04/04/01', 'DD/MM/YY'), 'can', 10);

with times(time_id) as (
  select TO_DATE('01/04/01', 'DD/MM/YY') from dual
  union all
  select time_id + 1
  from   times
  where  time_id < TO_DATE('06/04/01', 'DD/MM/YY') 
)
SELECT times.time_id, product, quantity FROM inventory 
   PARTITION BY  (product) 
   RIGHT OUTER JOIN times ON (times.time_id = inventory.time_id) 
   WHERE times.time_id BETWEEN TO_DATE('01/04/01', 'DD/MM/YY') 
      AND TO_DATE('06/04/01', 'DD/MM/YY') 
   ORDER BY  2,1
;
with times(time_id) as (
  select TO_DATE('01/04/01', 'DD/MM/YY') from dual
  union all
  select time_id + 1
  from   times
  where  time_id < TO_DATE('06/04/01', 'DD/MM/YY') 
)
SELECT time_id, product, LAST_VALUE(quantity IGNORE NULLS) 
   OVER (PARTITION BY product ORDER BY time_id) quantity 
   FROM ( SELECT times.time_id, product, quantity 
             FROM inventory PARTITION BY  (product) 
                RIGHT OUTER JOIN times ON (times.time_id = inventory.time_id) 
   WHERE times.time_id BETWEEN TO_DATE('01/04/01', 'DD/MM/YY') 
      AND TO_DATE('06/04/01', 'DD/MM/YY')) 
   ORDER BY  2,1
; 
drop TABLE inventory;
