select a.tablespace_name tablespace,
       d.mb_total,
       sum(a.used_blocks * d.block_size) / 1024 / 1024 mb_used,
       d.mb_total - sum(a.used_blocks * d.block_size) / 1024 / 1024 mb_free
from   v$sort_segment a,
       (select b.name,
               c.block_size,
               sum(c.bytes) / 1024 / 1024 mb_total
        from   v$tablespace b,
               v$tempfile   c
        where  b.ts# = c.ts#
        group  by b.name,
                  c.block_size) d
where  a.tablespace_name = d.name
group  by a.tablespace_name,
          d.mb_total
