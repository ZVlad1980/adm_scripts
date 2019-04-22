create or replace package pdh_gateway_reg_pkg is

  -- Author  : VZHURAVOV
  -- Created : 12/10/2018 2:31:23 PM
  -- Purpose : Registration of PDH Modules into API Gateway
  
  /**
   * Procedure add_module put the data of module into tables of API Gateway
   *   If module exists - procedure modify data of module
   */
  procedure add_module(
    p_module      in out nocopy pdh_gateway_module_typ,
    p_description pdh_gateway_modules_t.description%type default null,
    p_commit      boolean default false
  );

end pdh_gateway_reg_pkg;
/
