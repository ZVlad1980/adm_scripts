select get_table_alterxml('TAB1', 'TAB2') alterxml,
       dbms_metadata_diff.compare_alter_xml('TABLE','TAB1','TAB2') alterxml_md
from   dual;
