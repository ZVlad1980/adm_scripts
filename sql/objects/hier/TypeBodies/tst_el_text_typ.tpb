create or replace type body tst_el_text_typ is
  
  -- Member procedures and functions
  constructor function tst_el_text_typ return self as result is
  begin
    return;
  end;
  constructor function tst_el_text_typ(
    p_content    varchar2
  ) return self as result is
  begin
    self.content(p_content);
    return;
  end;
  --
  member procedure content(p_content varchar2) is
  begin
    self.content# := p_content;
  end;
  
  member function content return varchar2 is
  begin
    return self.content#;
  end;
  -- Member functions and procedures
  overriding member function get_element return varchar2 is
  begin
    return self.content;
  end;
  overriding member function is_leave return varchar2 is
  begin
    return 'Y';
  end;
  
end;
/
