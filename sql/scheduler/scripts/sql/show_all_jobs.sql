select * from   (
select nvl(p.name, 'CDB$ROOT') pdb_name,
       nvl(p.OPEN_MODE, 'READ WRITE') open_mode,
       j.OWNER,
       j.JOB_NAME,
       j.ENABLED
from   CDB_SCHEDULER_JOBS j,
       v$pdbs           p
where  1=1
--and    nvl(p.OPEN_MODE(+), 'READ WRITE') = 'READ WRITE'
and    p.con_id(+) = j.con_id
and    j.ENABLED = 'TRUE'

order by j.con_id, j.job_name, j.owner
) where open_mode = 'READ WRITE'
