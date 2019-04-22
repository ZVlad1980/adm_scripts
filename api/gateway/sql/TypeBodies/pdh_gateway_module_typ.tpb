create or replace type body pdh_gateway_module_typ is
  
  constructor function pdh_gateway_module_typ return self as result is
  begin
    self.parameters := pdh_gateway_params_typ();
    return;
  end;
  
  constructor function pdh_gateway_module_typ(
    p_module_name    varchar2,
    p_action_name    varchar2,
    p_unit_name      varchar2,
    p_routine_name   varchar2,
    p_parameters     pdh_gateway_params_typ,
    p_owner          varchar2 default null
  ) return self as result is
  begin
    self.module_name  := p_module_name  ;
    self.action_name  := p_action_name  ;
    self.owner        := p_owner        ;
    self.unit_name    := p_unit_name    ;
    self.routine_name := p_routine_name ;
    self.parameters   := p_parameters   ;
    return;
  end;
  --
  member function get_param_tbl return pdh_gateway_param_tbl_typ is
  begin
    return self.parameters.parameters;
  end get_param_tbl;
  --
  member function get_launch_cmd(
    p_parameters     in out nocopy pdh_gateway_params_typ
  ) return varchar2 is
    l_result varchar2(32767);
  begin
    l_result := 'begin ' || nvl(self.owner, user) || '.' || self.unit_name || '.' || self.routine_name || '(' ||
      self.parameters.get_launch_params(p_parameters).get_launch_str() || '); end;';
    return l_result;
  end get_launch_cmd;
  
end;
/
