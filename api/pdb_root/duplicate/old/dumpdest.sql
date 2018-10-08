--connect / as sysdba
PROMPT
PROMPT
PROMPT -- RESET DUMP DESTS:
alter system reset background_dump_dest scope=spfile;
alter system reset core_dump_dest scope=spfile;
alter system reset user_dump_dest scope=spfile;
--exit
