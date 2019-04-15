create or replace type body tst_attribute_typ is
  
  -- Member procedures and functions
  constructor function tst_attribute_typ return self as result is
  begin
    return;
  end ;
  
  constructor function tst_attribute_typ(
    p_name  varchar2,
    p_value varchar2
  ) return self as result is
  begin
    self.name(p_name);
    self.value(p_value);
    return;
  end ;
  --
  member procedure value(p_value varchar2)  is
  begin
    self.value# := substr(p_value, 1, 2000);
  end value;
  
  member function value return varchar2 is
  begin
    return self.value#;
  end value;
  --
  overriding member function get_element return varchar2 is
  begin
    return self.name || '="' || self.value || '"';
  end get_element;
  
  overriding member function is_leave return varchar2 is
  begin
    return 'Y';
  end is_leave;
  
end;
/
