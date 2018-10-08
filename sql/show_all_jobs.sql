select p.PDB_NAME,
       j.*
from   cdb_pdbs           p,
       CDB_SCHEDULER_JOBS j
where  j.con_id =  p.con_id
