PL/SQL Developer Test script 3.0
44
-- Created on 4/23/2019 by VZHURAVOV 
declare 
  -- Local variables here
  c integer;
  dummy int;
  rc sys_refcursor;
  val   int;
  procedure show_stat(p_msg varchar2) is
  begin
    dbms_output.put(p_msg || ': ');
    if dbms_sql.is_open(c) then
      dbms_output.put_line('Cursor is opened');
    else
      dbms_output.put_line('Cursor is closed');
    end if;
  end;
begin
  -- Test statements here
  c := dbms_sql.open_cursor(security_level => 2);
  show_stat('After open');
  dbms_sql.parse(
    c             => c,
    statement     => 'select level lvl from dual connect by level < 6',
    language_flag => dbms_sql.Native
  );
  show_stat('After parse');
  dummy := dbms_sql.execute(c);
  show_stat('After execute');
  rc := dbms_sql.to_refcursor(c);
  show_stat('After to_refcursor');
  loop
    fetch rc into val;
    exit when rc%notfound;
    dbms_output.put_line(val);
  end loop;
  
  close rc;
  
exception
  when others then
    if rc%isopen then close rc; end if;
    if c is not null and dbms_sql.is_open(c) then dbms_sql.close_cursor(c); end if;
    raise;
end;
0
0
