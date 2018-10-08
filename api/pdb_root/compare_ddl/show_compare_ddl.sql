SELECT compare_table_sxml('TAB1','TAB2') compare_ddl,
       dbms_metadata_diff.compare_sxml('TABLE','TAB1','TAB2') compare_ddl_md
FROM   dual;
