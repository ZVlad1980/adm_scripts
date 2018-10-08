/*
select *
from   all_objects ao
where  (ao.owner, ao.object_name, ao.object_type) in (
          select s.owner,
                 s.name,
                 s.type
          from   all_source s
          where  1=1
          and    (
                   (lower(s.text) like '%fetch first%')
                  or
                   (lower(s.text) like '%fetch next%')
                 )
          and    s.type = 'PACKAGE BODY'
          and    s.owner in (
                   select au.username
                   from   all_users au
                   where  au.common = 'NO'
                 )
       )
/
*/
with w_source as (
  select /*+ materialize*/
         s.owner,
         s.name,
         s.type,
         trim(lower(s.text)) text
  from   all_source s
  where  1 = 1
  --and    lower(s.text) not like '%to_number%'
  and    (
           (lower(s.text) like '%fetch first%')
          or
           (lower(s.text) like '%fetch next%')
         )
  and    s.type = 'PACKAGE BODY'
  and    s.owner in (select au.username
                     from   all_users au
                     where  au.common = 'NO')
)
select s.owner,
       s.name,
       s.type,
       s.text,
       regexp_instr(s.text, 'fetch next ') ins,
       regexp_instr(s.text, '[[:digit:]]') ins2
from   w_source s
--where  s.text not like '%to_number%'
/
