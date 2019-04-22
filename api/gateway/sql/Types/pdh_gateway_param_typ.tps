create or replace type pdh_gateway_param_typ as object(
  -- Author  : VZHURAVOV
  -- Created : 11/29/2018 4:41:36 PM
  -- Purpose : 
  
  -- Attributes
  parameter_id    int,
  parameter_name  varchar2(30),
  parameter_value varchar2(2048),
  
  -- Member functions and procedures
  constructor function pdh_gateway_param_typ return self as result,
  constructor function pdh_gateway_param_typ(
    p_name  varchar2
  ) return self as result,
  constructor function pdh_gateway_param_typ(
    p_name  varchar2,
    p_value varchar2
  ) return self as result,
  
  member function get_name  return varchar2,
  member function get_value return varchar2,
  member function get_launch_str return varchar2,
  member procedure set_value(p_value varchar2)
)
/
