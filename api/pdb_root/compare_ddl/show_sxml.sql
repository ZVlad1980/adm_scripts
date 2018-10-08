SELECT get_table_sxml('TAB1') tab1,
       get_table_sxml('TAB2') tab2,
       dbms_metadata.get_sxml('TABLE','TAB1') tab1_md,
       dbms_metadata.get_sxml('TABLE','TAB2') tab2_md,
FROM   dual
/
