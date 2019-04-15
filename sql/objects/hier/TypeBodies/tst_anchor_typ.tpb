create or replace type body tst_anchor_typ is
  
  -- Member procedures and functions
  member function version return varchar2 is
  begin
    return self.get_version_part('major') || '.' ||
      self.get_version_part('minor') || '.' ||
      self.get_version_part('release')
    ;\
  end;
  
end;
/
