Rem
Rem $Header: rdbms/admin/noncdb_to_pdb.sql /st_rdbms_12.1.0.1/9 2013/04/14 20:05:50 talliu Exp $
Rem
Rem noncdb_to_pdb.sql
Rem
Rem Copyright (c) 2011, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      noncdb_to_pdb.sql - Convert PDB
Rem
Rem    DESCRIPTION
Rem      Converts DB to PDB.
Rem
Rem    NOTES
Rem      Given a DB with proper obj$ common bits set, we convert it to a proper
Rem      PDB by deleting unnecessary metadata.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sankejai    04/11/13 - 16530655: do not update status in container$
Rem    pyam        04/03/13 - rename temp cdb$* views, to not interfere when
Rem                           this is run in multiple PDBs simultaneously
Rem    pyam        02/06/13 - error out for non-CDB
Rem    pyam        01/21/13 - stop exiting on sqlerror at end
Rem    pyam        01/15/13 - leave PDB in state in which it started
Rem    pyam        11/30/12 - delete services SYS$BACKGROUND and SYS$USERS
Rem    jomcdon     11/16/12 - bug 15894059: fix DBRM code for non-SYS
Rem    pyam        11/15/12 - set nls_length_semantics=byte
Rem    pyam        11/13/12 - skip old version types, update common user bit
Rem    jomcdon     11/07/12 - bug 14800566: fix resource manager plans for pdb
Rem    pyam        10/18/12 - add _noncdb_to_pdb
Rem    pyam        09/27/12 - support plug of upgraded db
Rem    pyam        08/13/12 - remove switches from PL/SQL, disable system triggers
Rem    pyam        06/26/12 - rename script to noncdb_to_pdb.sql
Rem    pyam        02/23/12 - validate v_$parameter properly
Rem    pyam        09/29/11 - Created
Rem

SET ECHO ON
SET SERVEROUTPUT ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

WHENEVER SQLERROR EXIT;

DOC
#######################################################################
#######################################################################
   The following statement will cause an "ORA-01403: no data found"
   error if we're not in a PDB.
   This script is intended to be run right after plugin of a PDB,
   while inside the PDB.
#######################################################################
#######################################################################
#

VARIABLE cdbname VARCHAR2(128)
VARIABLE pdbname VARCHAR2(128)
BEGIN
  SELECT sys_context('USERENV', 'CDB_NAME') 
    INTO :cdbname
    FROM dual
    WHERE sys_context('USERENV', 'CDB_NAME') is not null;
  SELECT sys_context('USERENV', 'CON_NAME') 
    INTO :pdbname
    FROM dual
    WHERE sys_context('USERENV', 'CON_NAME') <> 'CDB$ROOT';
END;
/

COLUMN pdbname NEW_VALUE pdbname
COLUMN pdbid NEW_VALUE pdbid

select :pdbname pdbname from dual;

select TO_CHAR(con_id) pdbid from v$pdbs where name='&pdbname';

-- save pluggable database open mode
COLUMN open_state_col NEW_VALUE open_sql;
COLUMN restricted_col NEW_VALUE restricted_state;
SELECT decode(open_mode,
              'READ ONLY', 'ALTER PLUGGABLE DATABASE &pdbname OPEN READ ONLY',
              'READ WRITE', 'ALTER PLUGGABLE DATABASE &pdbname OPEN', '')
         open_state_col,
       decode(restricted, 'YES', 'RESTRICTED', '')
         restricted_col
       from v$pdbs where name='&pdbname';

-- save value for _system_trig_enabled parameter
COLUMN sys_trig NEW_VALUE sys_trig_enabled  NOPRINT;
SELECT parm_values.ksppstvl as sys_trig
   FROM sys.x$ksppi parms, sys.x$ksppsv parm_values
   WHERE parms.ksppinm = '_system_trig_enabled' AND
         parms.inst_id = USERENV('Instance') AND
         parms.indx = parm_values.indx;

-- if pdb was already closed, don't exit on error
WHENEVER SQLERROR CONTINUE;

alter pluggable database "&pdbname" close;

WHENEVER SQLERROR EXIT;

alter session set container = CDB$ROOT;
alter system flush shared_pool;
/
/
alter session set container = "&pdbname";

alter pluggable database "&pdbname" open restricted;

-- initial setup before beginning the script
alter session set "_ORACLE_SCRIPT"=true;
alter session set "_NONCDB_TO_PDB"=true;
ALTER SESSION SET NLS_LENGTH_SEMANTICS=BYTE; 
ALTER SYSTEM SET "_system_trig_enabled"=FALSE SCOPE=MEMORY;
exec dbms_pdb.noncdb_to_pdb(1);

-- if we're plugging in a database that had been upgraded, we need to:
-- 1) generate signatures for common tables
-- 2) patch up tables that with column order differences. This can happen due
--    to db creation scripts adding columns to the middle of a table vs
--    upgrade scripts adding to the end via ALTER TABLE ADD 

alter session set container=CDB$ROOT;

-- create temporary object-linked view to get list of objects marked as common
-- in CDB$ROOT
create or replace view sys.cdb$common_root_objects&pdbid sharing=object as
select u.name owner, o.name object_name, o.type# object_type, o.namespace nsp,
       o.subname object_subname, o.signature object_sig,
       decode(bitand(o.flags, 65536), 65536, 'MDL', 'OBL') sharing
  from sys.obj$ o, sys.user$ u where
  o.owner#=u.user# and bitand(o.flags, 196608) <> 0;

-- object-linked view for list of common users
create or replace view sys.cdb$common_users&pdbid sharing=object as
select name from sys.user$ where bitand(spare1, 128) <> 0;

-- object-linked view for accessing dependency$
create or replace view sys.cdb$rootdeps&pdbid sharing=object as select du.name as owner, do.name as name, do.type# as d_type#, do.namespace as d_namespace,pu.name as referenced_owner, po.name as referenced_name, po.type# as p_type#, po.namespace as p_namespace,d.order#,d.property,d.d_attrs,d.d_reason from sys.obj$ do, sys.obj$ po, sys.user$ du, sys.user$ pu, sys.dependency$ d where du.user#=do.owner# and pu.user#=po.owner# and do.obj#=d_obj# and po.obj#=p_obj#;

-- switch into PDB
alter session set container="&pdbname";

create or replace view sys.cdb$common_root_objects&pdbid sharing=object as
select u.name owner, o.name object_name, o.type# object_type, o.namespace nsp,
       o.subname object_subname, o.signature object_sig,
       decode(bitand(o.flags, 65536), 65536, 'MDL', 'OBL') sharing
  from sys.obj$ o, sys.user$ u where
  o.owner#=u.user# and bitand(o.flags, 196608) <> 0;

create or replace view sys.cdb$common_users&pdbid sharing=object as
select name from sys.user$ where bitand(spare1, 128) <> 0;

create or replace view sys.cdb$rootdeps&pdbid sharing=object as select du.name as owner, do.name as name, do.type# as d_type#, do.namespace as d_namespace,pu.name as referenced_owner, po.name as referenced_name, po.type# as p_type#, po.namespace as p_namespace,d.order#,d.property,d.d_attrs,d.d_reason from sys.obj$ do, sys.obj$ po, sys.user$ du, sys.user$ pu, sys.dependency$ d where du.user#=do.owner# and pu.user#=po.owner# and do.obj#=d_obj# and po.obj#=p_obj#;

create or replace view sys.cdb$objects&pdbid sharing=none as
select u.name owner, o.name object_name, o.signature object_sig, o.namespace nsp,
       o.subname object_subname, o.obj# object_id, o.type# object_type, o.flags flags
  from sys.obj$ o, sys.user$ u
  where o.owner#=u.user#;

create or replace view sys.cdb$tables&pdbid sharing=none as
select * from sys.cdb$objects&pdbid where object_type=2;


---------------------------------------------------------------------------
-- PRE-SCRIPT CHECKS GO HERE:

set serveroutput on

-- Check that we have no invalid table data
DOC
#######################################################################
#######################################################################

     The following statement will cause an "ORA-01722: invalid number"
     error, if the database contains invalid data as a result of type
     evolution which was performed without the data being converted.
     
     To resolve this specific "ORA-01722: invalid number" error:
       Perform the data conversion (details below) in the pluggable database.

     Please refer to Oracle Database Object-Relational Developer's Guide
     for more information about type evolution.

     Data in columns of evolved types must be converted before the
     database can be converted.

     The following commands, run inside the PDB, will perform the data
     conversion for Oracle supplied data:

     @?/rdbms/admin/utluppkg.sql
     SET SERVEROUTPUT ON;
     exec dbms_preup.run_fixup_and_report('INVALID_SYS_TABLEDATA');
     SET SERVEROUTPUT OFF;

     You should then confirm that any non-Oracle supplied data is also
     converted.  You should review the data and determine if it needs
     to be converted or removed. 

     To view the data that is affected by type evolution, execute the
     following inside the PDB:

     SELECT rpad(u.name,128) TABLENAME, rpad(o.name,128) OWNER,
       rpad(c.name,128) COLNAME FROM SYS.OBJ$ o, SYS.COL$ c, SYS.COLTYPE$ t,
         SYS.USER$ u
         WHERE o.OBJ# = t.OBJ# AND c.OBJ# = t.OBJ# AND c.COL# = t.COL#
           AND t.INTCOL# = c.INTCOL# AND BITAND(t.FLAGS, 256) = 256
           AND o.OWNER# = u.USER# AND o.OWNER# NOT IN
            (SELECT UNIQUE (d.USER_ID) FROM SYS.DBA_USERS d, SYS.REGISTRY$ r
               WHERE d.USER_ID = r.SCHEMA# and r.NAMESPACE='SERVER');

     Once the data is confirmed, the following commands, run inside the PDB, 
     will convert the data returned by the above query.

     @?/rdbms/admin/utluppkg.sql
     SET SERVEROUTPUT ON;
     exec dbms_preup.run_fixup_and_report('INVALID_USR_TABLEDATA');
     SET SERVEROUTPUT OFF;

     Depending on the amount of data involved, converting the evolved type
     data can take a significant amount of time.

     After this is complete, please rerun noncdb_to_pdb.sql.

#######################################################################
#######################################################################
#

declare
  do_abort boolean := false;
begin
  if dbms_preup.condition_exists ('INVALID_SYS_TABLEDATA') then
    -- dump out the info
    dbms_preup.run_check('INVALID_SYS_TABLEDATA');
    do_abort := TRUE;
  end if;
  if dbms_preup.condition_exists ('INVALID_USR_TABLEDATA') THEN
    -- dump out the info
    dbms_preup.run_check('INVALID_USR_TABLEDATA');
    do_abort := TRUE;
  END IF;
  If do_abort THEN
    dbms_output.put_line ('Invalid table data.');
    dbms_output.put_line ('Non-CDB conversion aborting.');
    dbms_output.put_line ('For instructions, look for ORA-01722 in this script.');
    dbms_output.put_line ('Please resolve these and rerun noncdb_to_pdb.sql.');
    RAISE INVALID_NUMBER;
  end if;
end;
/

-- END PRE-SCRIPT CHECKS
---------------------------------------------------------------------------

-- mark users and roles in our PDB as common if they exist as common in ROOT
DECLARE
  cursor c is
    select p.user# from sys.cdb$common_users&pdbid r, sys.user$ p
    where r.name=p.name and bitand(p.spare1, 128)=0;
BEGIN
  FOR u in c
  LOOP
    BEGIN
      execute immediate 'update sys.user$ set spare1=spare1+128 where user#=' ||
                        u.user#;
    END;
  END LOOP;
  commit;
END;
/

select to_char(sysdate, 'Dy DD-Mon-YYYY HH24:MI:SS') from dual;

-- mark objects in our PDB as common if they exist as common in ROOT
DECLARE
  cursor c is
    select p.object_id, p.flags-bitand(p.flags, 196608) flags,
           decode(r.sharing, 'MDL', 65536, 131072) sharing_flag
      from sys.cdb$common_root_objects&pdbid r, sys.cdb$objects&pdbid p
    where r.owner=p.owner and r.object_name=p.object_name
      and r.object_type=p.object_type and r.nsp=p.nsp
      and (p.object_subname is null and r.object_subname is null
           or r.object_subname=p.object_subname)
      and decode(bitand(p.flags, 196608), 65536, 'MDL', 131072, 'OBL', 'NONE')<>r.sharing;
BEGIN
  null;/*FOR obj in c
  LOOP
    BEGIN
      execute immediate 'update sys.obj$ set flags=' || (obj.flags + obj.sharing_flag) ||
                        ' where obj#=' || obj.object_id;
    END;
  END LOOP;
  commit;*/
END;
/

select to_char(sysdate, 'Dy DD-Mon-YYYY HH24:MI:SS') from dual;

-- generate signatures for the common tables which don't have them
DECLARE
  cursor c is
    select r.owner, r.object_name
      from sys.cdb$common_root_objects&pdbid r, sys.cdb$tables&pdbid p
    where r.owner=p.owner and r.object_name=p.object_name
      and r.object_type=2 and p.object_sig is null
      and p.object_name not in ('OBJ$', 'USER$');
BEGIN
  FOR tab in c
  LOOP
    BEGIN
      execute immediate 'ALTER TABLE ' || tab.owner || '."' ||
                        tab.object_name || '" UPGRADE';
    EXCEPTION
      WHEN OTHERS THEN
      BEGIN
        IF (sqlcode = -600 or sqlcode = -602 or sqlcode = -603) THEN
          raise;
        END IF;
      END;
    END;
  END LOOP;
  commit;
END;
/

-- for each table whose signature doesn't match ROOT's, mark its PL/SQL
-- dependents for local MCode 
DECLARE
  cursor c is
    select obj#
      from sys.obj$ o, sys.user$ u, sys.cdb$common_root_objects&pdbid ro
    where o.type# <> 4 and u.name=ro.owner and u.user#=o.owner#
      and o.name=ro.object_name and o.type#=ro.object_type and obj# in
      (select d_obj# from sys.dependency$ where p_obj# in
        (select p.object_id from sys.CDB$common_root_objects&pdbid r,
                                 sys.cdb$tables&pdbid p
         where r.owner=p.owner and r.object_name=p.object_name
           and r.object_type=2 and r.object_sig <> p.object_sig));
BEGIN
  FOR obj in c
  LOOP
    execute immediate
      'update sys.obj$ set flags=flags+33554432-bitand(flags, 33554432) where obj#=' || obj.obj#;
  END LOOP;
  commit;
END;
/

select owner#, name from sys.obj$ where bitand(flags, 33554432)=33554432
  order by 1, 2;

-- Step (II)
--
-- Mark all metadata links as status 6
-- skip types w/ non-null subname
update sys.obj$ set status = 6
        where (type# not in (2, 28, 29, 30, 56))
        and (type# <> 13 or subname is null)
        and status not in (5,6)
        and bitand(flags, 65536)=65536;

commit
/

-- Invalidate all synonym dependents of dbms_standard. If not we will end up
-- with a timestamp mismatch between dependency  and obj

update sys.obj$ set status=6 where obj# in
(select d_obj# from sys.dependency$
 where p_obj# in (select obj# from sys.obj$ where name='DBMS_STANDARD' and
                  type# in ( 9, 11) and owner#=0)
) and type#=5
/
commit
/

alter system flush shared_pool
/

alter system flush shared_pool;
/
/

-- Step (II)
--
-- Recreate package standard and dbms_standard. This is needed to execute
-- subsequent anonymous blocks
SET ECHO OFF
@@standard
@@dbmsstdx

SET ECHO ON
-- Step (III)
--
-- Invalidate views and synonyms which depend (directly or indirectly) on
-- invalid objects.
begin
  loop
    update sys.obj$ o_outer set status = 6
    where     type# in (4, 5)
          and status not in (5, 6)
          and linkname is null
          and ((subname is null) or (subname <> 'DBMS_DBUPGRADE_BABY'))
          and exists (select o.obj# from sys.obj$ o, sys.dependency$ d
                      where     d.d_obj# = o_outer.obj#
                            and d.p_obj# = o.obj#
                            and (bitand(d.property, 1) = 1)
                            and o.status > 1);
    exit when sql%notfound;
  end loop;
end;
/
commit;

alter system flush shared_pool;
/
/

-- normalize dependencies for classes.bin objects
delete from sys.dependency$ where d_obj# in (select obj# from sys.obj$ where bitand(flags,65600)=65600);

insert into sys.dependency$ (select do.obj#,do.stime,order#,po.obj#,po.stime,do.owner#,property,d_attrs,d_reason from sys.obj$ do,sys.user$ du,sys.obj$ po,sys.user$ pu,sys.cdb$rootdeps&pdbid rd where du.user#=do.owner# and pu.user#=po.owner# and do.name=rd.name and du.name=owner and do.type#=d_type# and po.name=referenced_name and pu.name=referenced_owner and po.type#=p_type# and bitand(do.flags,65600)=65600);

commit;

-- get rid of idl_ub1$ rows for MDL java objects
delete from sys.idl_ub1$ where obj# in (select obj# from sys.obj$ where bitand(flags, 65536)=65536 and type# in (28,29,30,56));
commit;

alter system flush shared_pool;
/

-- explicitly compile these now, before close/reopen. Otherwise they would
-- be used/validated within PDB Open, where such patching (clearing of dict
-- rows) can't be done.
alter public synonym ALL_OBJECTS compile; 
alter view V_$PARAMETER compile;

WHENEVER SQLERROR CONTINUE;
alter type ANYDATA compile;
WHENEVER SQLERROR EXIT;

alter system flush shared_pool;
/
/
/

-- reopen the PDB
alter pluggable database "&pdbname" close;
alter pluggable database "&pdbname" open restricted;
ALTER SYSTEM SET "_system_trig_enabled"=FALSE SCOPE=MEMORY;

alter session set "_ORACLE_SCRIPT"=false;

select status, count(*) from sys.obj$ where status in (5, 6) group by status order by 1;
select count(*) from sys.view$;
select count(*) from sys.obj$ where bitand(flags, 65536)=65536 and obj# in
  (select obj# from sys.view$);
select count(*) from sys.procedure$;
select count(*) from sys.obj$ where bitand(flags, 65536)=65536 and obj# in
  (select obj# from sys.procedure$);
select count(*) from sys.dir$;
select count(*) from sys.obj$ where bitand(flags, 65536)=65536 and obj# in
  (select obj# from sys.dir$);

@@utlrp

select status, count(*) from sys.obj$ where status in (5, 6) group by status order by 1;
select count(*) from sys.view$;
select count(*) from sys.obj$ where bitand(flags, 65536)=65536 and obj# in
  (select obj# from sys.view$);
select count(*) from sys.procedure$;
select count(*) from sys.obj$ where bitand(flags, 65536)=65536 and obj# in
  (select obj# from sys.procedure$);
select count(*) from sys.dir$;
select count(*) from sys.obj$ where bitand(flags, 65536)=65536 and obj# in
  (select obj# from sys.dir$);

-- mark old version types as valid, as utlrp skips these
update sys.obj$ set status = 1
  where type#=13 and subname is not null and status > 1;
commit;

alter pluggable database "&pdbname" close;
alter system flush shared_pool;
/
/
alter pluggable database "&pdbname" open restricted;
ALTER SYSTEM SET "_system_trig_enabled"=FALSE SCOPE=MEMORY;

alter session set "_ORACLE_SCRIPT"=true;
drop view sys.cdb$tables&pdbid;
drop view sys.cdb$objects&pdbid;
drop view sys.cdb$common_root_objects&pdbid;
drop view sys.cdb$common_users&pdbid;
drop view sys.cdb$rootdeps&pdbid;

alter session set container=CDB$ROOT;
drop view sys.cdb$common_root_objects&pdbid;
drop view sys.cdb$common_users&pdbid;
drop view sys.cdb$rootdeps&pdbid;

alter session set container="&pdbname";

-- handle Resource Manager plan conversions
exec dbms_rmin.rm$_noncdb_to_pdb;

-- delete SYS$BACKGROUND and SYS$USERS from service$
delete from sys.service$ where name in ('SYS$BACKGROUND', 'SYS$USERS');
commit;

-- reset the parameters at the end of the script
exec dbms_pdb.noncdb_to_pdb(2);
alter session set "_ORACLE_SCRIPT"=false;
alter session set "_NONCDB_TO_PDB"=false;
ALTER SYSTEM SET "_system_trig_enabled"=&sys_trig_enabled SCOPE=MEMORY;

alter pluggable database "&pdbname" close;
alter session set container = CDB$ROOT;
alter system flush shared_pool;
/
/
alter session set container = "&pdbname";

-- leave the PDB in the same state it was when we started
BEGIN
  execute immediate '&open_sql &restricted_state';
EXCEPTION
  WHEN OTHERS THEN
  BEGIN
    IF (sqlcode <> -900) THEN
      RAISE;
    END IF;
  END;
END;
/

WHENEVER SQLERROR CONTINUE;
