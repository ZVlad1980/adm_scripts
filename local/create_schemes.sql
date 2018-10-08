
/* --create tablespaces
CREATE BIGFILE TABLESPACE GFNDDATA;
CREATE TABLESPACE GFNDDATA DATAFILE '/opt/oracle/oradata/ORCLCDB/ORCLPDB2/gfnddata_01.dbf' SIZE 20000M AUTOEXTEND ON NEXT 1000M;
ALTER TABLESPACE GFNDDATA ADD DATAFILE '/opt/oracle/oradata/ORCLCDB/ORCLPDB2/gfnddata_02.dbf' SIZE 20000M AUTOEXTEND ON NEXT 1000M;
ALTER TABLESPACE GFNDDATA ADD DATAFILE '/opt/oracle/oradata/ORCLCDB/ORCLPDB2/gfnddata_03.dbf' SIZE 20000M AUTOEXTEND ON NEXT 1000M;
ALTER TABLESPACE GFNDDATA ADD DATAFILE '/opt/oracle/oradata/ORCLCDB/ORCLPDB2/gfnddata_04.dbf' SIZE 20000M AUTOEXTEND ON NEXT 1000M;
ALTER TABLESPACE GFNDDATA ADD DATAFILE '/opt/oracle/oradata/ORCLCDB/ORCLPDB2/gfnddata_05.dbf' SIZE 20000M AUTOEXTEND ON NEXT 1000M;
ALTER TABLESPACE GFNDDATA ADD DATAFILE '/opt/oracle/oradata/ORCLCDB/ORCLPDB2/gfnddata_06.dbf' SIZE 20000M AUTOEXTEND ON NEXT 1000M;
ALTER TABLESPACE GFNDDATA ADD DATAFILE '/opt/oracle/oradata/ORCLCDB/ORCLPDB2/gfnddata_07.dbf' SIZE 20000M AUTOEXTEND ON NEXT 1000M;
/*
ALTER DATABASE MOVE DATAFILE '/opt/oracle/oradata/ORCLCDB/ORCLPDB1/gfnddata_01.dbf' TO '/opt/oracle/oradata/ORCLCDB/ORCLPDB2/gfnddata_01.dbf';
ALTER DATABASE MOVE DATAFILE '/opt/oracle/oradata/ORCLCDB/ORCLPDB1/gfnddata_02.dbf' TO '/opt/oracle/oradata/ORCLCDB/ORCLPDB2/gfnddata_02.dbf';
ALTER DATABASE MOVE DATAFILE '/opt/oracle/oradata/ORCLCDB/ORCLPDB1/gfnddata_03.dbf' TO '/opt/oracle/oradata/ORCLCDB/ORCLPDB2/gfnddata_03.dbf';
*/
--*/

ALTER SESSION SET "_ORACLE_SCRIPT"=true;
--drop user fnd cascade
/*
*/
declare
  l_users sys.odcivarchar2list :=
    sys.odcivarchar2list(
      'cdm',
      'gazfond',
      'fnd'
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
        ei_('CREATE USER #SCHEMA_NAME IDENTIFIED BY #schema_name DEFAULT TABLESPACE GFNDDATA QUOTA UNLIMITED ON GFNDDATA'); 
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
    end;
  end;
  --
  procedure create_dump_dir(p_name varchar2) is
    l_name varchar2(32);
  begin
    l_name := lower(p_name);
    ei(l_name, 'CREATE OR REPLACE DIRECTORY dump_dir_#SCHEMA_NAME AS ''gfdump/#SCHEMA_NAME''');
    ei(l_name, 'GRANT READ, WRITE ON DIRECTORY dump_dir_#SCHEMA_NAME  TO #SCHEMA_NAME');
  end;
begin
  for i in 1..l_users.count loop
    --create_user(l_users(i));
    create_dump_dir(l_users(i));
    dbms_output.put_line('');
  end loop;
end;
/
