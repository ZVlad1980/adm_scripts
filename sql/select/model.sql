CREATE OR REPLACE VIEW sales_view_ref AS
  SELECT country_name country,
         prod_name prod,
         calendar_year year,
         SUM(amount_sold) sale,
         COUNT(amount_sold) cnt
    FROM sales,times,customers,countries,products
    WHERE sales.time_id = times.time_id
      AND sales.prod_id = products.prod_id
      AND sales.cust_id = customers.cust_id
      AND customers.country_id = countries.country_id
      AND ( customers.country_id = 52779
            OR customers.country_id = 52776 )
      AND ( prod_name = 'Standard Mouse'
            OR prod_name = 'Mouse Pad' )
    GROUP BY country_name,prod_name,calendar_year
;
SELECT country, prod, year, sale
  FROM sales_view_ref
  ORDER BY country, prod, year
;
/*
The next example creates a multidimensional array from sales_view_ref with columns containing:
    country, product, year, and sales. 
  It also:
    - Assigns the sum of the sales of the Mouse Pad for years 1999 and 2000 to the sales of the Mouse Pad 
      for year 2001, if a row containing sales of the Mouse Pad for year 2001 exists.
    - Assigns the value of sales of the Standard Mouse for year 2001 to sales of the Standard Mouse for year 2002, 
      creating a new row if a row containing sales of the Standard Mouse for year 2002 does not exist.
*/
SELECT country,prod,year,s
  FROM sales_view_ref
  MODEL
    PARTITION BY (country)
    DIMENSION BY (prod, year)
    MEASURES (sale s)
    IGNORE NAV
    UNIQUE DIMENSION
    RULES UPSERT SEQUENTIAL ORDER
    (
      s[prod='Mouse Pad', year=2001] =
        s['Mouse Pad', 1999] + s['Mouse Pad', 2000],
      s['Standard Mouse', 2002] = s['Standard Mouse', 2001]
    )
  ORDER BY country, prod, year
;
--The next example uses the same sales_view_ref view and the analytic function SUM 
--  to calculate a cumulative sum (csum) of sales per country and per year.
SELECT country, year, sale, csum
   FROM 
   (SELECT country, year, SUM(sale) sale
    FROM sales_view_ref
    GROUP BY country, year
   )
   MODEL DIMENSION BY (country, year)
         MEASURES (sale, 0 csum) 
         RULES (csum[any, any]= 
                  SUM(sale) OVER (PARTITION BY country 
                                  ORDER BY year 
                                  ROWS UNBOUNDED PRECEDING) 
                )
   ORDER BY country, year
;
