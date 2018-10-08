CREATE BIGFILE TABLESPACE GFNDDATA datafile size 90G AUTOEXTEND ON NEXT 100M MAXSIZE 120G blocksize 16K;
CREATE OR REPLACE DIRECTORY gfdump_cdm_dir       AS 'gfdump/cdm';
CREATE OR REPLACE DIRECTORY gfdump_fnd_dir       AS 'gfdump/fnd';
CREATE OR REPLACE DIRECTORY gfdump_gazfond_dir   AS 'gfdump/gazfond';
CREATE OR REPLACE DIRECTORY gfdump_config_dir    AS 'gfdump_config';
