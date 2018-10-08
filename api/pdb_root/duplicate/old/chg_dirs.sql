--connect / as sysdba
PROMPT
PROMPT -- CHANGE EXPORT DIRECTORIES:
CREATE OR REPLACE DIRECTORY dpexp_dir1 AS '/ora1/buf/work/buf/dpe';
CREATE OR REPLACE DIRECTORY dpexp_dir2 AS '/ora1/buf/work/buf/add';
CREATE OR REPLACE DIRECTORY dpexp_bit  AS '/ora1/buf/work/buf/bit';
GRANT READ,WRITE ON DIRECTORY DPEXP_BIT TO INF, INF_PN, MDM;
--exit
