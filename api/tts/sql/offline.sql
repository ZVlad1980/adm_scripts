CREATE OR REPLACE DIRECTORY data_dump_dir AS '/ora1/buf/datapump'
/
ALTER DATABASE dataFILE '/ora1/dat/tstdb/dbs/system01.dbf' RESIZE 11G
/
alter tablespace DWHDATA read only;
alter tablespace FONDDATA read only;
alter tablespace FONDINDX read only;
alter tablespace USERDATA read only;
alter tablespace WEBDATA read only;
alter tablespace ARHDATA read only;
alter tablespace MDMDATA read only;
alter tablespace OPSDATA read only;
alter tablespace INFDATA read only;
alter tablespace GFNDINDX read only;
alter tablespace CTXDATA read only;
alter tablespace MDMDAT2 read only;
alter tablespace FIASDATA read only;
alter tablespace GFNDDAT2 read only;
alter tablespace GFPNDATA read only;
alter tablespace GFPNINDX read only;
alter tablespace SMPPDATA read only;
alter tablespace ETL_DATA read only;
alter tablespace ETL_INDX read only;
/
/*
alter tablespace DWHDATA offline;
alter tablespace FONDDATA offline;
alter tablespace FONDINDX offline;
alter tablespace USERDATA offline;
alter tablespace WEBDATA offline;
alter tablespace ARHDATA offline;
alter tablespace MDMDATA offline;
alter tablespace OPSDATA offline;
alter tablespace INFDATA offline;
alter tablespace GFNDINDX offline;
alter tablespace CTXDATA offline;
alter tablespace MDMDAT2 offline;
alter tablespace FIASDATA offline;
alter tablespace GFNDDAT2 offline;
alter tablespace GFPNDATA offline;
alter tablespace GFPNINDX offline;
alter tablespace SMPPDATA offline;
*/
