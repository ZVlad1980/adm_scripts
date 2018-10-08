/*
alter session set "_oracle_script"=true;
drop user gazfond cascade;
CREATE USER gazfond IDENTIFIED BY gazfond    DEFAULT TABLESPACE GFNDDAT2 QUOTA UNLIMITED ON GFNDDAT2 QUOTA UNLIMITED ON GFNDINDX;
GRANT DBA TO gazfond;
*/
alter session set "_oracle_script"=true;
drop user cdm cascade;
CREATE USER cdm IDENTIFIED BY cdm    DEFAULT TABLESPACE GFNDDAT2 QUOTA UNLIMITED ON GFNDDAT2 QUOTA UNLIMITED ON GFNDINDX;
GRANT DBA TO cdm;
