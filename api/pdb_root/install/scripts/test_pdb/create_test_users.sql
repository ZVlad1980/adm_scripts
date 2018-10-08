CREATE BIGFILE TABLESPACE GFNDDATA datafile size 500M AUTOEXTEND ON NEXT 100M MAXSIZE 2G blocksize 16K
/
declare
  l_users sys.odcivarchar2list :=
    sys.odcivarchar2list(
      'cdm',
      'fnd',
      'gazfond',
      'gazfond_pn'
    );
  l_dummy pls_integer;
  --
  procedure ei(p_name varchar2, p_cmd varchar2) is
    l_cmd varchar2(512);
  begin
    l_cmd := replace(replace(p_cmd, '#SCHEMA_NAME', p_name), '#schema_name', lower(p_name));
    dbms_output.put(rpad(l_cmd || '  ', 80, '.') || ' ');
    execute immediate l_cmd;
    dbms_output.put_line('Ok');
  exception
    when others then
      dbms_output.put_line(sqlerrm);
  end ei;
  --
  procedure create_user(p_name varchar2) is
    --
    l_name varchar2(32);
    procedure ei_(p_cmd varchar2) is
    begin
      ei(l_name, p_cmd);
    end;
  begin
    l_name := upper(p_name);
    begin
      dbms_output.put('User ' || l_name || ' ');
      select 1
      into   l_dummy
      from   all_users u
      where  u.username = l_name;
      dbms_output.put_line(lpad(' exists', 80, '.'));
      --ei_('alter user #SCHEMA_NAME IDENTIFIED BY #schema_name');
    exception
      when no_data_found then
        dbms_output.put_line(' creation log:');
        ei_('CREATE USER #SCHEMA_NAME IDENTIFIED BY #schema_name DEFAULT TABLESPACE GFNDDATA QUOTA 100M ON GFNDDATA'); 
        ei_('GRANT RESOURCE, CONNECT, EXP_FULL_DATABASE, IMP_FULL_DATABASE TO #SCHEMA_NAME');
        ei_('GRANT CREATE ANY SYNONYM TO #SCHEMA_NAME');
        ei_('GRANT ALTER ANY TRIGGER TO #SCHEMA_NAME');
        ei_('GRANT CREATE ANY CONTEXT TO #SCHEMA_NAME');
        ei_('GRANT CREATE ANY TABLE TO #SCHEMA_NAME');
        ei_('GRANT CREATE ANY TRIGGER TO #SCHEMA_NAME');
        ei_('GRANT CREATE CREDENTIAL TO #SCHEMA_NAME');
        ei_('GRANT CREATE DATABASE LINK TO #SCHEMA_NAME');
        ei_('GRANT CREATE INDEXTYPE TO #SCHEMA_NAME');
        ei_('GRANT CREATE JOB TO #SCHEMA_NAME');
        ei_('GRANT CREATE MATERIALIZED VIEW TO #SCHEMA_NAME');
        ei_('GRANT CREATE OPERATOR TO #SCHEMA_NAME');
        ei_('GRANT CREATE PROCEDURE TO #SCHEMA_NAME');
        ei_('GRANT CREATE PUBLIC DATABASE LINK TO #SCHEMA_NAME');
        ei_('GRANT CREATE PUBLIC SYNONYM TO #SCHEMA_NAME');
        ei_('GRANT CREATE SEQUENCE TO #SCHEMA_NAME');
        ei_('GRANT CREATE SESSION TO #SCHEMA_NAME');
        ei_('GRANT CREATE SYNONYM TO #SCHEMA_NAME');
        ei_('GRANT CREATE TABLE TO #SCHEMA_NAME');
        ei_('GRANT CREATE TRIGGER TO #SCHEMA_NAME');
        ei_('GRANT CREATE TYPE TO #SCHEMA_NAME');
        ei_('GRANT CREATE VIEW TO #SCHEMA_NAME');
        ei_('GRANT DEBUG ANY PROCEDURE TO #SCHEMA_NAME');
        ei_('GRANT DEBUG CONNECT SESSION TO #SCHEMA_NAME');
        ei_('GRANT DROP PUBLIC DATABASE LINK TO #SCHEMA_NAME');
        ei_('GRANT DROP PUBLIC SYNONYM TO #SCHEMA_NAME');
        --
        ei(p_name, 'create table ' || p_name || '.test(id int, code varchar2(32), describe varchar2(200))');
        ei(p_name, 'insert into ' || p_name || '.test(id, code, describe)values(1, ''' || p_name || ''', ''GF user ' || p_name || ''')');
        --
    end;
  end create_user;
begin
  for i in 1..l_users.count loop
    create_user(l_users(i));
    dbms_output.put_line('');
  end loop;
end;
/
