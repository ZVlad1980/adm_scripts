-------------------------------------------------
-- gfpn_chg.sql
--              - Changes props for GAZFOND_PN:
--
-- NOTE: this script mustn't have any parameters
--
--   (c) U2R 18.03.16
-------------------------------------------------
PROMPT
PROMPT -- CHANGE GAZFOND_PN PROPERTIES:
--
update gazfond_pn.app_settings t 
    set t.application_title='Test Environment' where id=0;
--alter user gazfond_pn identified by test_123;
PROMPT
PROMPT -- ADD PRIVS FOR RLS:
--
grant create any context to gazfond_pn;
grant execute on dbms_rls to gazfond_pn;
--
PROMPT
PROMPT -- CREATE LOGON TRIGGER:
--
create or replace trigger gazfond_pn_chg_sess after logon on gazfond_pn.schema
begin
  execute immediate 'alter session set "_optimizer_adaptive_plans"=false';
end;
/
--
