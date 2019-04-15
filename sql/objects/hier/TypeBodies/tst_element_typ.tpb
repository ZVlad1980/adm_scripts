create or replace type body tst_element_typ is
  
  -- Member procedures and functions
  constructor function tst_element_typ return self as result is
  begin
    self.attributes#  := tst_attributes_typ();
    self.childs#      := tst_elements#_typ();
    return;
  end;
  constructor function tst_element_typ(
    p_tag        varchar2,
    p_content    tst_elements#_typ,
    p_attributes tst_attributes_typ default null
  ) return self as result is
  begin
    self := tst_element_typ();
    self.name(p_tag);
    self.attributes# := nvl(p_attributes, self.attributes#);
    self.childs#     := nvl(p_content, self.childs#);
    return;
  end;
  constructor function tst_element_typ(
    p_tag        varchar2,
    p_content    varchar2,
    p_attributes tst_attributes_typ default null
  ) return self as result is
  begin
    self := tst_element_typ(
      p_tag        => p_tag,
      p_content    => tst_elements#_typ(tst_el_text_typ(p_content)),
      p_attributes => p_attributes
    );
    return;
  end;
  --
  member function attributes return varchar2 is
    l_result varchar2(32767);
  begin
    for i in 1..self.attributes#.count loop
      l_result := l_result || case when l_result is not null then ' ' end || self.attributes#(i).get_element();
    end loop;
    return case when l_result is not null then ' ' end || l_result;
  end;
  --
  member function childs return varchar2 is
    l_result varchar2(32767);
  begin
    for i in 1..self.childs#.count loop
      l_result := l_result || self.childs#(i).get_element();
    end loop;
    return l_result;
  end;
  --
  overriding member function get_element return varchar2 is
  begin
    return '<' || self.name || self.attributes() || '>' || self.childs() || '</' || self.name || '>';
  end get_element;
  
  overriding member function is_leave return varchar2 is
  begin
    return case when self.childs#.count > 0 then 'N' else 'Y' end;
  end is_leave;
  
end;
/
