select t.id,
       rpad('=', level - 1, '=') || '>' lvl,
       t.pdb_name,
       t.pdb_parent,
       t.open_mode,
       t.refreshable,
       t.freeze,
       t.default_parent,
       t.clone_of_clone,
       t.childs_exists,
       t.childs_freeze,
       t.pdb_created,
       t.creator,
       t.last_open_mode,
       t.created_at,
       t.updated_at,
       'drop pluggable database ' || t.pdb_name || ' including datafiles;' cmd,
       t.rowid
from   pdb_clones_v t
start with t.pdb_parent is null
connect by prior t.pdb_name = t.pdb_parent
order siblings by t.pdb_created

/*
show pdbs

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 PDB_ROOT                       READ WRITE NO
         4 DEV_NODE                       MOUNTED
         5 DEV_CLONE                      READ ONLY  NO
         6 DEV                            READ WRITE NO
         7 PDB_RELEASE1                   READ WRITE NO
         8 DDECLONE1                      READ WRITE NO
         9 ANIKIN_TSTDB                   READ WRITE NO
        10 DEV_VBZ                        MOUNTED
        11 WEEKLY_NODE                    MOUNTED
        12 WEEKLY_CLONE                   READ ONLY  NO

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
        13 WEEKLY                         READ WRITE NO
        14 WEEKLY_VBZ                     READ WRITE NO
        15 WEEKLY_NDFL                    READ WRITE NO
        16 WEEKLY_ASSIGN                  READ WRITE NO

*/

