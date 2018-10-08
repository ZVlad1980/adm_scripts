--https://docs.oracle.com/database/121/ADMIN/memory.htm#ADMIN11200
SELECT name, sum(value/1024/1024) "Size Mb"
FROM v$statname n,
     v$session s,
     v$sesstat t
WHERE s.sid=t.sid
  AND n.statistic# = t.statistic#
  AND s.type = 'USER'
  AND s.username is not NULL
  AND n.name in ('session pga memory', 'session pga memory max', 
      'session uga memory', 'session uga memory max')
GROUP BY name
