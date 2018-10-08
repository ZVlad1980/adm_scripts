select *
from   v$recovery_file_dest;
/
select *
from   v$recovery_area_usage;
/
select ROUND((SPACE_USED)/1024/1024/1024) "Used GB", 
ROUND((SPACE_LIMIT)/1024/1024/1024) "MAX GB", 
ROUND(((SPACE_LIMIT)-(SPACE_USED))/1024/1024/1024) "FREE GB" 
from V$recovery_File_Dest;
