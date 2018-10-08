select t.id, 
       t.pdb_name, 
       t.lvl,
       t.pdb_parent, 
       t.open_mode,     --текущий режим PDB (столбец обновляется автоматически)
       t.refreshable,   --обновление PDB (пересоздание): NO/DAILY/UDPATE_PARENT - Не обновляется/Ежедневно/После обновления родительской PDB
       t.freeze,        --заморозка PDB: YES/NO. При заморозке - запрещены любые операции в отношенни PDB - изменение режима, удаление и т.д.
       t.pdb_created,   --время создания PDB (столбец заполняется автоматически, по факту создания PDB)
       t.creator,     
       t.default_parent --PDB родитель по умолчанию в операциях клонирования
from   pdb_clones t
