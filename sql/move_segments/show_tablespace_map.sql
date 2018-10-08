--http://www.sql.ru/forum/1264759/umenshenie-razmera-tablichnogo-prostranstva?mid=20608172#20608172
select owner,
       segment_name,
       partition_name,
       segment_type,
       tablespace_name tbs,
       block_id,
       bytes / power(1024, 3) "Gbytes",
       blocks,
       relative_fno fno,
       ' ' free
from   dba_extents
where  tablespace_name = '' -- указываем ТП
union all
select ' ' owner,
       ' ' segment_name,
       ' ' partition_name,
       ' ' segment_type,
       tablespace_name tbs,
       block_id,
       bytes / power(1024, 3) "Gbytes",
       blocks,
       relative_fno fno,
       'Free' free
from   dba_free_space
where  tablespace_name = '' -- указываем ТП
order  by fno,
          block_id desc
