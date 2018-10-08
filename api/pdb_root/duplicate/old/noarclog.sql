--connect / as sysdba
PROMPT
PROMPT -- SHUTDOWN:
alter user system identified by "system->tstdb";
alter user sys identified by "sys#tst_ora";
shutdown immediate
PROMPT
PROMPT -- STARTUP NOMOUNT:
startup mount
PROMPT
PROMPT -- NOARCHIVELOG:
alter database noarchivelog;
PROMPT
PROMPT -- RESTART::
shutdown immediate
startup
--exit
