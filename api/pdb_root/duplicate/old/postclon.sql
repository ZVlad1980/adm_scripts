connect / as sysdba
-- 1. Reset dump destinations.
@dumpdest.sql
-- 2. Change to NOARCLOG.
@noarclog.sql
-- 3. Change export directories.
@chg_dirs.sql
-- 4. Disable jobs.
alter system set job_queue_processes=0 scope=both;
-- 5. Set additional parameters.
alter system set "_use_single_log_writer"=TRUE scope=spfile;
alter system set "_kdt_buffering"=FALSE scope=spfile;
--
-- 6. Changes GAZFOND & GAZFOND_PN users.
@gfnd_chg.sql
@gfpn_chg.sql
--
exit
