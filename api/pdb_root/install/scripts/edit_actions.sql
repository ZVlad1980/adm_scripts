select t.*,
       t.rowid
from   pdb_actions_v t
order  by t.created_at desc, t.id desc
