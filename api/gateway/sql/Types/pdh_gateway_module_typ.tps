create or replace type pdh_gateway_module_typ as object
(
  -- Author  : VZHURAVOV
  -- Created : 11/30/2018 9:20:27 AM
  -- Purpose : 
  
  -- Attributes
  module_id      int,
  action_id      int,
  
  module_name    varchar2(30),
  action_name    varchar2(30),
  --
  owner          varchar2(30),
  unit_name      varchar2(30),
  routine_name   varchar2(30),
  parameters     pdh_gateway_params_typ,
  
  -- Member functions and procedures
  constructor function pdh_gateway_module_typ return self as result,
  constructor function pdh_gateway_module_typ(
    p_module_name    varchar2,
    p_action_name    varchar2,
    p_unit_name      varchar2,
    p_routine_name   varchar2,
    p_parameters     pdh_gateway_params_typ,
    p_owner          varchar2 default null
  ) return self as result,
  --
  member function get_param_tbl return pdh_gateway_param_tbl_typ,
  --
  member function get_launch_cmd(
    p_parameters     in out nocopy pdh_gateway_params_typ
  ) return varchar2
)
/
