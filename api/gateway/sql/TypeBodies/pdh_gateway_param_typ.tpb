create or replace type body pdh_gateway_param_typ is
  
  -- Member procedures and functions
  constructor function pdh_gateway_param_typ return self as result is
  begin
    return;
  end;
  
  constructor function pdh_gateway_param_typ(
    p_name  varchar2
  ) return self as result is
  begin
    self := pdh_gateway_param_typ();
    self.parameter_name := p_name;
    return;
  end;
  
  constructor function pdh_gateway_param_typ(
    p_name  varchar2,
    p_value varchar2
  ) return self as result is
  begin
    self := pdh_gateway_param_typ(p_name => p_name);
    self.set_value(p_value);
    return;
  end;
  
  member function get_name
  return varchar2 is
  begin
    return self.parameter_name;
  end get_name;
  
  member function get_value 
    return varchar2 is
  begin
    return self.parameter_value;
  end get_value;
  
  member function get_launch_str return varchar2 is
  begin
    return self.get_name() || ' => ' || '''' || replace(self.get_value(), '''', '''''') || '''';
  end get_launch_str;
  
  member procedure set_value(p_value varchar2) is
  begin
    self.parameter_value := p_value;
  end set_value;
end;
/
