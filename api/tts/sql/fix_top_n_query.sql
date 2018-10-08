declare
  l_relplaces sys.odcivarchar2list := 
    sys.odcivarchar2list(
      'GAZFOND',
       'DOCLIST_PKG',
       'OFFSET pagingStart ROWS FETCH NEXT pagingSize ROWS ONLY;',
       'OFFSET to_number(pagingStart) ROWS FETCH NEXT to_number(pagingSize) ROWS ONLY;',
      'GAZFOND_PN',
       'DOCLIST_PKG',
       'OFFSET pagingStart ROWS FETCH NEXT pagingSize ROWS ONLY;',
       'OFFSET to_number(pagingStart) ROWS FETCH NEXT to_number(pagingSize) ROWS ONLY;',
      'SASHA',
       'FIRSTPAY_REGISTER',
       'offset nvl(pStart,0) rows',
       'offset nvl(to_number(pStart) ,0) rows',
      'SASHA',
       'FIRSTPAY_REGISTER',
       'fetch first nvl(pLimit,nLimit) rows only; ',
       'fetch first nvl(to_number(pLimit), to_number(nLimit)) rows only; ',
      'GAZFOND_PN',
       'PAY_OPSREG1_PKG',
       'offset nvl(pStart,0) rows',
       'offset nvl(to_number(pStart) ,0) rows',
      'GAZFOND_PN',
       'PAY_OPSREG1_PKG',
       'fetch first nvl(pLimit,nLimit) rows only;',
       'fetch first nvl(to_number(pLimit), to_number(nLimit)) rows only;'
    );
  l_ddl clob;
  l_idx int;
  
  function get_status(p_owner varchar2, p_name varchar2) return varchar2 is
    l_status all_objects.status%type;
  begin
    select o.status
    into   l_status
    from   all_objects o
    where  o.owner = p_owner
    and    o.object_name = p_name
    and    o.object_type = 'PACKAGE BODY';
    return l_status;
  exception
    when no_data_found then
      return 'NOTFOUND';
  end get_status;
  
begin
  for i in 1..l_relplaces.count/4 loop
    case get_status(l_relplaces((i - 1) * 4 + 1), l_relplaces((i - 1) * 4 + 2))
      when 'NOTFOUND' then
        l_ddl := '';
      else
        l_ddl := replace(
          replace(
            dbms_metadata.get_ddl(
              'PACKAGE_BODY',
              l_relplaces((i - 1) * 4 + 2),
              l_relplaces((i - 1) * 4 + 1)
            ),
            l_relplaces((i - 1) * 4 + 3),
            l_relplaces((i - 1) * 4 + 4)
          ),
          'CREATE OR REPLACE EDITIONABLE PACKAGE',
          'CREATE OR REPLACE PACKAGE'
        );
    end case;
    
    begin
      if dbms_lob.getlength(l_ddl) > 0 then
        execute immediate l_ddl;
      end if;
    exception
      when others then
        dbms_output.put_line('Compile package body ' || l_relplaces((i - 1) * 4 + 1) || '.' || l_relplaces((i - 1) * 4 + 2) || ' failed: ' || sqlerrm);
    end;
  end loop;
end;
/
