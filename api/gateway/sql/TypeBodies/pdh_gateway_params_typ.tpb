create or replace type body pdh_gateway_params_typ is
  
  -- Member procedures and functions
  constructor function pdh_gateway_params_typ return self as result is
  begin
    self.parameters := pdh_gateway_param_tbl_typ();
    self.curr_pos$ := 0;
    return;
  end;
  
  constructor function pdh_gateway_params_typ(
    p_parameters pdh_gateway_param_tbl_typ
  ) return self as result is
  begin
    self := pdh_gateway_params_typ();
    self.parameters := p_parameters;
    self.curr_pos$ := 1;
    return;
  end;
  
  /*constructor function pdh_gateway_params_typ(p_json varchar2) return self as result is
  begin
    self := pdh_gateway_params_typ();
    self.parameters.extend(2);
    self.parameters(1) := pdh_gateway_param_typ(p_name => 'P_ROWID_SYSTEM', p_value => 'JANIS');
    self.parameters(2) := pdh_gateway_param_typ(p_name => 'P_PRODUCT_TYPE', p_value => 'JOURNAL');
    self.curr_pos$ := 1;
    return;
  end;
  */
  
  --member function get_value(self in out pdh_gateway_params_typ,    p_name varchar2  ) return pdh_gateway_param_typ.value%type is
  member function get_launch_params(
    p_parameters in out nocopy pdh_gateway_params_typ
  ) return pdh_gateway_params_typ is
    l_result pdh_gateway_params_typ;
  begin
    l_result := pdh_gateway_params_typ();
    
    for i in 1..self.parameters.count loop
      if p_parameters.find(self.parameters(i).get_name()) then
        l_result.add_parameter(p_parameters.get_curr_parameter());
      end if;
    end loop;
    
    return l_result;
  end get_launch_params;
  
  member function get_launch_str return varchar2 is
    l_result varchar2(4000);
  begin
    
    for i in 1..self.parameters.count loop
      l_result := l_result || case when l_result is not null then ', ' end || self.parameters(i).get_launch_str();
    end loop;
    
    return l_result;
    
  end get_launch_str;
  
  member procedure add_parameter(p_parameter pdh_gateway_param_typ) is
  begin
    self.parameters.extend;
    self.parameters(self.parameters.count) := p_parameter;
  end;
  
  member function get_curr_parameter return pdh_gateway_param_typ is
  begin
    
    if self.parameters is null or not self.parameters.exists(self.curr_pos$) then
      raise no_data_found;
    end if;
    
    return self.parameters(self.curr_pos$);
    
  end get_curr_parameter;
  
  -- navigation method
  member procedure first is
  begin
    self.curr_pos$ := 1;
  end first;
  --member function next(self in out pdh_gateway_params_typ, p_value out varchar2) return boolean,
  --member function next(self in out pdh_gateway_params_typ, p_name out varchar2) return boolean,
  member function next(
    self in out pdh_gateway_params_typ
  ) return boolean is
  begin
    if self.parameters is null or nvl(self.curr_pos$, 0) >= self.parameters.count then
      return false;
    end if;
    self.curr_pos$ := nvl(self.curr_pos$, 0) + 1;
    return true;
  end next;
  
  member function next(
    self    in out pdh_gateway_params_typ,
    p_name  out varchar2,
    p_value out varchar2
  ) return boolean is
    l_result boolean;
  begin
    l_result := false;
    if self.next() then
      l_result := true;
      p_name  := self.parameters(self.curr_pos$).get_name();
      p_value := self.parameters(self.curr_pos$).get_value();
    end if;
    
    return l_result;
  end next;
  
  member function find(self in out pdh_gateway_params_typ, p_name varchar2) return boolean is
    l_result boolean;
  begin
    l_result := false;
    for i in 1..self.parameters.count loop
      if self.parameters(i).get_name() = p_name then
        l_result      := true;
        self.curr_pos$ := i;
        exit;
      end if;
    end loop;
    return l_result;
  end find;
  
end;
/
