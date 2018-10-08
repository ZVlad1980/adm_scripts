begin
    raise_application_error(-20000, 'Find me');
end;
/

select * from v$sql where sql_text like '%error(-20000, ''Find%'; 
