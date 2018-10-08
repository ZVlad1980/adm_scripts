select (column_value).getstringval() 
from xmltable('"a","b","c"')
/
select column_value, (column_value).getnumberval() 
from xmltable('1,2, 3 , 4 , 5 ,6')
/
