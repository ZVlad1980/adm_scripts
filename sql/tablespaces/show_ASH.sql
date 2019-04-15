--https://paulstuartoracle.wordpress.com/2014/07/20/analysing-temp-space-usage-with-ash-data/
select *
from   V$ACTIVE_SESSION_HISTORY
where session_id = 779
order by sample_time
