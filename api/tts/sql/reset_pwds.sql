begin
  for u in (
    select u.username
    from   all_users u
    where  u.common = 'NO'
    and    u.username not in ('PDB_ROOT', 'VBZ')
    ) loop
    execute immediate('alter user ' || u.username || ' identified by ' || lower(u.username));
  end loop;
end;








