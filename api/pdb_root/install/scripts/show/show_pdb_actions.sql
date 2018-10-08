select t.id, 
       t.action,       --код операции
       t.pdb_name,     --имя целевой PDB
       t.pdb_parent,   --имя родительской PDB
       t.planned_at,   --запланированное время выполнения операции
       t.status,       --стаус операции NEW/PROCESS/SUCCESS/ERROR
       t.created_at,   --дата создания записи
       t.updated_at    --дата последнего обновления записи
from   pdb_actions t
