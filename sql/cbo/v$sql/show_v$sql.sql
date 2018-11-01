/*
CONNECT oe@inst1
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM Customers;
CONNECT sh@inst1
SELECT COUNT(*) FROM customers;
*/
--
select d.username,
       s.sql_text,
       s.sql_id, --ID parent_cursor
       s.child_number, --if same sql_id in two or more lines
       s.hash_value,
       s.plan_hash_value
from   v$sql     s,
       dba_users d
where  sql_text like '%select emp.*, rowid from   hr.employees emp%'
and    sql_text not like '%SQL_TEXT%'
and    d.user_id = s.parsing_user_id
order by s.sql_id, s.child_number
;
--Cursor Mismatches
select *
from   V$SQL_SHARED_CURSOR scs
where  scs.sql_id = '8h916vv2yw400'
;
select s.sql_text,
       s.child_number,
       s.child_address,
       c.translation_mismatch,
       c.auth_check_mismatch
from   v$sql               s,
       v$sql_shared_cursor c
where  sql_text like '%ustom%'
and    sql_text not like '%SQL_TEXT%'
and    s.child_address = c.child_address
;
select sql_text,
       sql_id,
       version_count,
       hash_value
from   v$sqlarea
where  sql_text like '%ustom%'
and    sql_text not like '%SQL_TEXT%'
;
