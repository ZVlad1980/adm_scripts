select tt.owner,
           tt.object_type,
           tt.object_name,
           tt.status
    from   (
            select ao.owner,
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
            select t.owner, t.object_type, t.object_name, t.status
            from   vbz.tts_invalids_t t
           ) tt
    order by 
      case tt.object_type
        when 'PACKAGE' then 1
        when 'VIEW' then 2
        when 'SYNONYM' then 3
        else 99
      end;
/
