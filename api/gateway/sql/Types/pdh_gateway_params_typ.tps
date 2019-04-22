create or replace type pdh_gateway_params_typ as object
(
  -- Author  : VZHURAVOV
  -- Created : 11/29/2018 4:40:50 PM
  -- Purpose : 
  
  -- Attributes
  parameters pdh_gateway_param_tbl_typ,
  curr_pos$  integer,
  
  -- Member functions and procedures
  
  constructor function pdh_gateway_params_typ return self as result,
  constructor function pdh_gateway_params_typ(p_parameters pdh_gateway_param_tbl_typ) return self as result,
  --constructor function pdh_gateway_params_typ(p_json varchar2) return self as result,
  
  --constructor function pdh_gateway_params_typ(p_unit_params pdh_gateway_params_typ, p_value_params pdh_gateway_params_typ) return self as result,
  member function get_launch_params(p_parameters in out nocopy pdh_gateway_params_typ) return pdh_gateway_params_typ,
  member function get_launch_str return varchar2,
  member procedure add_parameter(p_parameter pdh_gateway_param_typ),
  --member function get_value(self in out pdh_gateway_params_typ, p_name varchar2) return varchar2,
  -- navigation method
  member procedure first,
  --member function next(self in out pdh_gateway_params_typ, p_value out varchar2) return boolean,
  --member function next(self in out pdh_gateway_params_typ, p_name out varchar2) return boolean,
  member function next(self in out pdh_gateway_params_typ) return boolean,
  member function next(self in out pdh_gateway_params_typ, p_name out varchar2, p_value out varchar2) return boolean,
  member function get_curr_parameter return pdh_gateway_param_typ,
  
  member function find(self in out pdh_gateway_params_typ, p_name varchar2) return boolean
)
/
