-------------------------------------------------
-- gfnd_chg.sql
--              - Changes props for GAZFOND:
--
-- NOTE: this script mustn't have any parameters
--
--   (c) U2R 18.03.16
-------------------------------------------------
PROMPT
PROMPT -- CHANGE GAZFOND PROPERTIES:
--
update gazfond.app_settings t 
    set t.application_title='Test Environment' where id=0;
alter user gazfond identified by test_123;
PROMPT
PROMPT -- ADD PRIVS FOR RLS:
--
grant create any context to gazfond;
grant execute on dbms_rls to gazfond;
--
PROMPT
PROMPT -- CREATE LOGON TRIGGER:
--
create or replace trigger gazfond_chg_sess after logon on gazfond.schema
begin
  execute immediate 'alter session set "_optimizer_adaptive_plans"=false';
end;
/
--
