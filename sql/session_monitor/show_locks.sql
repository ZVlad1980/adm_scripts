select l.type,
       case l.type
         when 'TM' then 'DML enqueue'
         when 'TX' then 'Transaction enqueue'
         when 'UL' then 'User supplied'
         else           'System type'
       end      lock_type,
       case l.lmode
         when 0 then 'none'
         when 1 then 'null (NULL)'
         when 2 then 'row-S (SS)'
         when 3 then 'row-X (SX)'
         when 4 then 'share (S)'
         when 5 then 'S/Row-X (SSX)'
         when 6 then 'exclusive (X)'
         else        'unknown: ' || l.lmode
       end       lock_mode,
       l.id1,
       l.id2,
       case l.request --Lock mode in which the process requests the lock
        when 0 then 'none'
        when 1 then 'null (NULL)'
        when 2 then 'row-S (SS)'
        when 3 then 'row-X (SX)'
        when 4 then 'share (S)'
        when 5 then 'S/Row-X (SSX)'
        when 6 then 'exclusive (X)'
        else        'unknown: ' || l.request
       end      request,
       o.object_type,
       o.owner || '.' || o.object_name object_name
from   sys.all_objects o,
       v$lock          l
where  1=1
and    l.type in ('TM', 'TX', 'UL')
and    o.object_id = l.id1
and    l.sid = 38
