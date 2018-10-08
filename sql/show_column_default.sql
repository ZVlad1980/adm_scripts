with 
  function get_default(p_table_name varchar2, p_column_name varchar2) return varchar2 is
    l_result varchar2(32767);
  begin
    select tc2.DATA_DEFAULT
    into   l_result
    from   user_tab_columns tc2
    where  tc2.TABLE_NAME = p_table_name
    and    tc2.COLUMN_NAME = p_column_name;
    return upper(trim(l_result));
  end;
select tc.*,
       ascii(substr(tc.data_default, length(tc.DATA_DEFAULT))) last_character_code
from   (select tc.TABLE_NAME,
               tc.COLUMN_NAME,
               tc.COLUMN_ID,
               tc.DATA_TYPE,
               tc.DATA_LENGTH,
               tc.DATA_PRECISION,
               tc.DATA_SCALE,
               tc.NULLABLE,
               get_default(tc.TABLE_NAME, tc.COLUMN_NAME) data_default,
               (select c.COMMENTS 
                from   user_tab_comments c 
                where  c.TABLE_NAME = tc.TABLE_NAME
                and    c.TABLE_TYPE = 'TABLE'
               ) table_comments,
               (select cc.COMMENTS 
                from   user_col_comments cc
                where  cc.TABLE_NAME = tc.TABLE_NAME
                and    cc.COLUMN_NAME = tc.COLUMN_NAME
               ) column_comments
        from   user_tab_columns tc
        where  1=1
        and    tc.DATA_TYPE = 'DATE'
        ) tc
where   1=1--
and     tc.data_default is not null
and     tc.data_default like 'TO_DATE(%))%'
