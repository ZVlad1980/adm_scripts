conn system/passwd@tstdb
@@set_env.sql
alter tablespace DWHDATA read write;
alter tablespace FONDDATA read write;
alter tablespace FONDINDX read write;
alter tablespace USERDATA read write;
alter tablespace WEBDATA read write;
alter tablespace ARHDATA read write;
alter tablespace MDMDATA read write;
alter tablespace OPSDATA read write;
alter tablespace INFDATA read write;
alter tablespace GFNDINDX read write;
alter tablespace CTXDATA read write;
alter tablespace MDMDAT2 read write;
alter tablespace FIASDATA read write;
alter tablespace GFNDDAT2 read write;
alter tablespace GFPNDATA read write;
alter tablespace GFPNINDX read write;
alter tablespace SMPPDATA read write;
alter tablespace ETL_DATA read write;
alter tablespace ETL_INDX read write;
exit success