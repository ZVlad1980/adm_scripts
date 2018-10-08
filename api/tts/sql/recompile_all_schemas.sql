declare
  cursor l_recomp_schemas_cur is
    select tt.owner
    from   (select ao.owner,
                   ao.object_type,
                   ao.object_name,
                   ao.status
            from   all_objects ao
            where  1 = 1
            and    ao.status <> 'VALID'
            and    ao.owner in (select u.username
                                from   all_users u
                                where  u.common = 'NO')
            minus
            select t.owner,
                   t.object_type,
                   t.object_name,
                   t.status
            from   vbz.tts_invalids_t t) tt
    group  by tt.owner;
begin
  for o in l_recomp_schemas_cur loop
    begin
      UTL_RECOMP.recomp_parallel(
        threads => 5,
        schema  => o.owner
      );
    exception
      when others then
        dbms_output.put_line('Compile ' || o.owner || ' failed. ' || sqlerrm);
    end;
  end loop;
end;
