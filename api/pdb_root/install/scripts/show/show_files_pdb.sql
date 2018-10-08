select e.*,
       regexp_substr(e.message, '[^ ]+', 1, 9)      file_name,
       substr(e.message, instr(e.message, '->') + 3) link
from   files_pdb_ext_t e
where  e.message like 'l%'
