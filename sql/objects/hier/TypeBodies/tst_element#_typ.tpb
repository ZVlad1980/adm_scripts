create or replace type body tst_element#_typ is
  
  -- Member procedures and functions
  member procedure name(p_name varchar2) is
  begin
    self.name# := substrb(p_name, 1, 50);
  end name;
  
  member function name return varchar2 is
  begin
    return self.name#;
  end name;
  
  overriding member function get_version_part(
    p_ver_type varchar2 --major/minor/release
  ) return int is
  begin
    return case p_ver_type
      when 'major' then 0
      when 'minor' then 0
      when 'release' then 1
    end;
  end get_version_part;
  
end;
/
