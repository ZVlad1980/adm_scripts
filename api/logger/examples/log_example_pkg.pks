create or replace package log_example_pkg is

  -- Author  : Zhuravov
  -- Created : 12/7/2018 8:57:59 AM
  -- Purpose : Example of use of API Logger
  
  -- Public type declarations
  procedure main(
    p_product_code  varchar2,
    p_from_date     date
  );
  
end log_example_pkg;
/
