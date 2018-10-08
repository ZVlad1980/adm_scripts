--http://www.sql.ru/forum/1264759/umenshenie-razmera-tablichnogo-prostranstva?mid=20608172#20608172
SELECT DISTINCT *
FROM (SELECT *
FROM (SELECT CASE segment_type
WHEN 'TABLE'
THEN
'execute immediate ''alter table "'
|| owner
|| '"."'
|| segment_name
|| '" move'';'
WHEN 'TABLE PARTITION'
THEN
'execute immediate ''alter table "'
|| owner
|| '"."'
|| segment_name
|| '" move partition "'
|| partition_name
|| '"'';'
WHEN 'INDEX'
THEN
'execute immediate ''alter index "'
|| owner
|| '"."'
|| segment_name
|| '" rebuild online'';'
WHEN 'INDEX PARTITION'
THEN
'execute immediate ''alter index "'
|| owner
|| '"."'
|| segment_name
|| '" rebuild partition "'
|| partition_name
|| '" online'';'
ELSE
' '
END
FROM (SELECT owner,
segment_name,
partition_name,
segment_type,
tablespace_name tbs,
block_id,
bytes / POWER (1024, 3) "Gbytes",
blocks,
relative_fno fno,
' ' Free
FROM dba_extents
WHERE tablespace_name = 'TABLESPACE' -- указываем ТП
UNION ALL
SELECT ' ' owner,
' ' segment_name,
' ' partition_name,
' ' segment_type,
tablespace_name tbs,
block_id,
bytes / POWER (1024, 3) "Gbytes",
blocks,
relative_fno fno,
'Free' Free
FROM dba_free_space
WHERE tablespace_name = 'TABLESPACE' -- указываем ТП
ORDER BY fno, block_id DESC))
WHERE ROWNUM <= X); -- указываем число первых блоков, которые хотим сместить вниз
