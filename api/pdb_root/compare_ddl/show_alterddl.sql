SELECT get_table_alterddl('TAB1','TAB2')  alterddl,
       dbms_metadata_diff.compare_alter('TABLE','TAB1','TAB2') alterddl_md
FROM dual;
