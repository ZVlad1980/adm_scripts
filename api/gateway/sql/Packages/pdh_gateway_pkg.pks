create or replace package pdh_gateway_pkg is

  -- Author  : VZHURAVOV
  -- Created : 11/26/2018 3:38:43 PM
  -- Purpose : Uniform gateway of PDH Modules
  GC_STS_SUCCESS constant varchar2(1) := 'S';
  GC_STS_ERROR   constant varchar2(1) := 'E';

  /**
   * 
   */
  function get_parameters_tbl(
    p_json varchar2
  ) return pdh_gateway_param_tbl_typ
  pipelined;

  /**
   * Main procedure for launch of PDH modules without retruns of results
   *
   * p_module - name of module
   * p_action - name of action
   * p_json   - list of parameters into JSON,
   * p_commit - commit or not (boolean  default true)
   *
   */
  procedure launch(
    p_module  varchar2 default null,
    p_action  varchar2 default null,
    p_json    varchar2 default null,
    p_commit  boolean  default true
  );

end pdh_gateway_pkg;
/
