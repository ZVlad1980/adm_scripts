declare
  --
  procedure set_transform_
  (
    p_name  varchar2,
    p_value boolean
  ) is
  begin
    dbms_metadata.set_transform_param(dbms_metadata.session_transform,
                                      p_name,
                                      p_value);
  end;
  --
begin
  --
  set_transform_('STORAGE', false);
  set_transform_('CONSTRAINTS', false);
  set_transform_('REF_CONSTRAINTS', false);
  set_transform_('SEGMENT_ATTRIBUTES', false);
  set_transform_('TABLESPACE', false);
  set_transform_('CONSTRAINTS_AS_ALTER', false);
  set_transform_('EMIT_SCHEMA', false);
  set_transform_('SQLTERMINATOR', true);
  set_transform_('SQLTERMINATOR', true);
  --
end;
/
select ut.TABLE_NAME, 
       replace(replace(dbms_metadata.get_dependent_ddl('CONSTRAINT', ut.TABLE_NAME), ut.TABLE_NAME, 'U' || ut.TABLE_NAME), '"') table_ddl,
       replace(replace(dbms_metadata.get_dependent_ddl('REF_CONSTRAINT', ut.TABLE_NAME), ut.TABLE_NAME, 'U' || ut.TABLE_NAME), '"') table_ddl2,
       replace(replace(dbms_metadata.get_dependent_ddl('INDEX', ut.TABLE_NAME), ut.TABLE_NAME, 'U' || ut.TABLE_NAME), '"') table_ddl3,
       'drop table u' || lower(ut.TABLE_NAME) || ';' drop_cmd
from   user_tables ut
where  ut.TABLE_NAME IN ('PEOPLE', 'CONTRACTS', 'CONTACTS', 'IDCARDS', 'ADDRESSES')
