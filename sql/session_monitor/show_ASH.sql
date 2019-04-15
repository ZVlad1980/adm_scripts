--https://paulstuartoracle.wordpress.com/2014/07/20/analysing-temp-space-usage-with-ash-data/
--https://www.doag.org/formes/pubfiles/6445684/2014-DB-David_Kurtz-Practical_ASH-Praesentation.pdf
select *
from   V$ACTIVE_SESSION_HISTORY
order by sample_time
/
select /*+leading(r x h) use_nl(h)*/
 h.sql_id,
 h.sql_plan_hash_value,
 count(distinct sql_exec_id) num_execs,
 sum(10) ash_secs,
 10 * count(distinct sample_id) elap_secs,
 round(max(temp_space_allocated) / 1024 / 1024, 0) tempmb,
 count(distinct r.prcsinstance) pis
from   dba_hist_snapshot            x,
       dba_hist_active_sess_history h,
       sysadm.psprcsrqst            r
where  …
order  by ash_secs desc
