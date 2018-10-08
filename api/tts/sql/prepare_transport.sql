create table gazfond.ISC_MSG$ as
select *
from   gazfond.ISC_MSG
/
create table gazfond.ISC_ACL$ as
select *
from   gazfond.ISC_ACL
/
create table gazfond.ISC_SRV$ as
select *
from   gazfond.ISC_SRV
/
drop table gazfond.ISC_MSG;
drop table gazfond.ISC_ACL;
drop table gazfond.ISC_SRV;
/
CREATE TABLE GAZFOND.ISC_SRV(
  ID NUMBER, 
  EXT_SRV_ID VARCHAR2(255) NOT NULL ENABLE, 
  INT_REV_ID NUMBER NOT NULL ENABLE, 
  LOC VARCHAR2(1024) NOT NULL ENABLE, 
  AUTH_REQ NUMBER(1,0) DEFAULT 0 NOT NULL ENABLE, 
  REQ_TYPE VARCHAR2(255) NOT NULL ENABLE, 
  RES_TYPE VARCHAR2(255) NOT NULL ENABLE, 
  DESCRIPTION VARCHAR2(2000), 
  CONSTRAINT ISC_SRV_PK PRIMARY KEY (ID)
)
/
CREATE UNIQUE INDEX GAZFOND.ISC_SRV_PARTLOC_IDX ON GAZFOND.ISC_SRV (EXT_SRV_ID)
/
CREATE UNIQUE INDEX GAZFOND.ISC_SRV_UK_IDX1 ON GAZFOND.ISC_SRV (EXT_SRV_ID, INT_REV_ID)
/
CREATE UNIQUE INDEX GAZFOND.ISC_SRV_UK_IDX2 ON GAZFOND.ISC_SRV (REQ_TYPE) 
/
CREATE UNIQUE INDEX GAZFOND.ISC_SRV_UK_IDX3 ON GAZFOND.ISC_SRV (RES_TYPE) 
/
COMMENT ON COLUMN GAZFOND.ISC_SRV.ID IS 'Внутренний идентификатор';
COMMENT ON COLUMN GAZFOND.ISC_SRV.EXT_SRV_ID IS 'Внешний идентификатор сервиса';
COMMENT ON COLUMN GAZFOND.ISC_SRV.INT_REV_ID IS 'Номер внутренней ревизии';
COMMENT ON COLUMN GAZFOND.ISC_SRV.LOC IS 'Один или несколько адресов, для разд. исп. символ <;> ';
COMMENT ON COLUMN GAZFOND.ISC_SRV.AUTH_REQ IS 'Доступ к сервису ограничен (1-да, 0-нет)';
COMMENT ON COLUMN GAZFOND.ISC_SRV.REQ_TYPE IS 'Тип, соотв. запросу к сервису';
COMMENT ON COLUMN GAZFOND.ISC_SRV.RES_TYPE IS 'Тип, соотв. ответу от сервиса';
COMMENT ON COLUMN GAZFOND.ISC_SRV.DESCRIPTION IS 'Описание метода сервиса';
COMMENT ON TABLE  GAZFOND.ISC_SRV  IS 'Справочник доступных сервисов.';
/
CREATE TABLE GAZFOND.ISC_MSG (
  MESSAGE_ID NUMBER DEFAULT CDM.ISC_MESSAGE_SEQ.NEXTVAL NOT NULL ENABLE, 
  FK_SERVICE NUMBER NOT NULL ENABLE, 
  TS DATE NOT NULL ENABLE, 
  ISC_ID RAW(16) NOT NULL ENABLE, 
  SEQ_N NUMBER NOT NULL ENABLE, 
  PAYLOAD CLOB NOT NULL ENABLE, 
  RHOST VARCHAR2(255), 
  USER_ID NUMBER NOT NULL ENABLE, 
  LABEL VARCHAR2(255), 
  CONSTRAINT ISC_MSG_PK PRIMARY KEY (MESSAGE_ID)
)
/
CREATE INDEX GAZFOND.ISC_MSG_IDX1 ON GAZFOND.ISC_MSG (FK_SERVICE) 
/
CREATE INDEX GAZFOND.ISC_MSG_IDX2 ON GAZFOND.ISC_MSG (ISC_ID, SEQ_N) 
/
CREATE INDEX GAZFOND.ISC_MSG_IDX3 ON GAZFOND.ISC_MSG (LABEL) 
/
COMMENT ON COLUMN GAZFOND.ISC_MSG.MESSAGE_ID IS 'Внутренний идентификатор';
COMMENT ON COLUMN GAZFOND.ISC_MSG.FK_SERVICE IS 'Ссылка на запись в справочнике ISC_SERVICE';
COMMENT ON COLUMN GAZFOND.ISC_MSG.TS IS 'Дата/время создания';
COMMENT ON COLUMN GAZFOND.ISC_MSG.ISC_ID IS 'Идентификатор последовательности';
COMMENT ON COLUMN GAZFOND.ISC_MSG.SEQ_N IS 'Порядковый номер в последовательности';
COMMENT ON COLUMN GAZFOND.ISC_MSG.PAYLOAD IS 'Содержание сообщения (запроса/ответа)';
COMMENT ON COLUMN GAZFOND.ISC_MSG.RHOST IS 'Служебное поле, может содерж. адрес конкр. экземпляра сервиса для продолж. обмена';
COMMENT ON COLUMN GAZFOND.ISC_MSG.USER_ID IS 'Идентификатор оператора(сотрудника), от кого поступил запрос';
COMMENT ON COLUMN GAZFOND.ISC_MSG.LABEL IS 'Опциональная метка произвольного формата';
COMMENT ON TABLE  GAZFOND.ISC_MSG  IS 'Данные обмена с сервисами (во внутреннем формате).'
/
CREATE TABLE GAZFOND.ISC_ACL (
  USR_ID NUMBER(10,0) NOT NULL ENABLE, 
  SRV_ID NUMBER(10,0) NOT NULL ENABLE, 
  CONSTRAINT ISC_ACL_UQ UNIQUE (USR_ID, SRV_ID)
) 
/
insert into GAZFOND.ISC_SRV select * from GAZFOND.ISC_SRV$
/
insert into GAZFOND.ISC_ACL select * from GAZFOND.ISC_ACL$
/
insert into GAZFOND.ISC_MSG select * from GAZFOND.ISC_MSG$
/
drop table gazfond.ISC_MSG$;
drop table gazfond.ISC_ACL$;
drop table gazfond.ISC_SRV$;
--
--GAZFOND_PN
--
create table gazfond_pn.ISC_MSG$ as
select *
from   gazfond_pn.ISC_MSG
/
create table gazfond_pn.ISC_SRV$ as
select *
from   gazfond_pn.ISC_SRV
/
drop table gazfond_pn.ISC_MSG;
drop table gazfond_pn.ISC_SRV;
/
CREATE TABLE gazfond_pn.ISC_SRV(
  ID NUMBER, 
  EXT_SRV_ID VARCHAR2(255) NOT NULL ENABLE, 
  INT_REV_ID NUMBER NOT NULL ENABLE, 
  LOC VARCHAR2(1024) NOT NULL ENABLE, 
  AUTH_REQ NUMBER(1,0) DEFAULT 0 NOT NULL ENABLE, 
  REQ_TYPE VARCHAR2(255) NOT NULL ENABLE, 
  RES_TYPE VARCHAR2(255) NOT NULL ENABLE, 
  DESCRIPTION VARCHAR2(2000), 
  CONSTRAINT ISC_SRV_PK PRIMARY KEY (ID)
)
/
CREATE UNIQUE INDEX gazfond_pn.ISC_SRV_PARTLOC_IDX ON gazfond_pn.ISC_SRV (EXT_SRV_ID)
/
CREATE UNIQUE INDEX gazfond_pn.ISC_SRV_UK_IDX1 ON gazfond_pn.ISC_SRV (EXT_SRV_ID, INT_REV_ID)
/
CREATE UNIQUE INDEX gazfond_pn.ISC_SRV_UK_IDX2 ON gazfond_pn.ISC_SRV (REQ_TYPE) 
/
CREATE UNIQUE INDEX gazfond_pn.ISC_SRV_UK_IDX3 ON gazfond_pn.ISC_SRV (RES_TYPE) 
/
COMMENT ON COLUMN gazfond_pn.ISC_SRV.ID IS 'Внутренний идентификатор';
COMMENT ON COLUMN gazfond_pn.ISC_SRV.EXT_SRV_ID IS 'Внешний идентификатор сервиса';
COMMENT ON COLUMN gazfond_pn.ISC_SRV.INT_REV_ID IS 'Номер внутренней ревизии';
COMMENT ON COLUMN gazfond_pn.ISC_SRV.LOC IS 'Один или несколько адресов, для разд. исп. символ <;> ';
COMMENT ON COLUMN gazfond_pn.ISC_SRV.AUTH_REQ IS 'Доступ к сервису ограничен (1-да, 0-нет)';
COMMENT ON COLUMN gazfond_pn.ISC_SRV.REQ_TYPE IS 'Тип, соотв. запросу к сервису';
COMMENT ON COLUMN gazfond_pn.ISC_SRV.RES_TYPE IS 'Тип, соотв. ответу от сервиса';
COMMENT ON COLUMN gazfond_pn.ISC_SRV.DESCRIPTION IS 'Описание метода сервиса';
COMMENT ON TABLE  gazfond_pn.ISC_SRV  IS 'Справочник доступных сервисов.';
/
CREATE TABLE gazfond_pn.ISC_MSG (
  MESSAGE_ID NUMBER DEFAULT CDM.ISC_MESSAGE_SEQ.NEXTVAL NOT NULL ENABLE, 
  FK_SERVICE NUMBER NOT NULL ENABLE, 
  TS DATE NOT NULL ENABLE, 
  ISC_ID RAW(16) NOT NULL ENABLE, 
  SEQ_N NUMBER NOT NULL ENABLE, 
  PAYLOAD CLOB NOT NULL ENABLE, 
  RHOST VARCHAR2(255), 
  USER_ID NUMBER NOT NULL ENABLE, 
  LABEL VARCHAR2(255), 
  CONSTRAINT ISC_MSG_PK PRIMARY KEY (MESSAGE_ID)
)
/
CREATE INDEX gazfond_pn.ISC_MSG_IDX1 ON gazfond_pn.ISC_MSG (FK_SERVICE) 
/
CREATE INDEX gazfond_pn.ISC_MSG_IDX2 ON gazfond_pn.ISC_MSG (ISC_ID, SEQ_N) 
/
CREATE INDEX gazfond_pn.ISC_MSG_IDX3 ON gazfond_pn.ISC_MSG (LABEL) 
/
COMMENT ON COLUMN gazfond_pn.ISC_MSG.MESSAGE_ID IS 'Внутренний идентификатор';
COMMENT ON COLUMN gazfond_pn.ISC_MSG.FK_SERVICE IS 'Ссылка на запись в справочнике ISC_SERVICE';
COMMENT ON COLUMN gazfond_pn.ISC_MSG.TS IS 'Дата/время создания';
COMMENT ON COLUMN gazfond_pn.ISC_MSG.ISC_ID IS 'Идентификатор последовательности';
COMMENT ON COLUMN gazfond_pn.ISC_MSG.SEQ_N IS 'Порядковый номер в последовательности';
COMMENT ON COLUMN gazfond_pn.ISC_MSG.PAYLOAD IS 'Содержание сообщения (запроса/ответа)';
COMMENT ON COLUMN gazfond_pn.ISC_MSG.RHOST IS 'Служебное поле, может содерж. адрес конкр. экземпляра сервиса для продолж. обмена';
COMMENT ON COLUMN gazfond_pn.ISC_MSG.USER_ID IS 'Идентификатор оператора(сотрудника), от кого поступил запрос';
COMMENT ON COLUMN gazfond_pn.ISC_MSG.LABEL IS 'Опциональная метка произвольного формата';
COMMENT ON TABLE  gazfond_pn.ISC_MSG  IS 'Данные обмена с сервисами (во внутреннем формате).'
/
CREATE TABLE gazfond_pn.ISC_ACL (
  USR_ID NUMBER(10,0) NOT NULL ENABLE, 
  SRV_ID NUMBER(10,0) NOT NULL ENABLE, 
  CONSTRAINT ISC_ACL_UQ UNIQUE (USR_ID, SRV_ID)
) 
/
insert into gazfond_pn.ISC_SRV select * from gazfond_pn.ISC_SRV$
/
insert into gazfond_pn.ISC_MSG select * from gazfond_pn.ISC_MSG$
/
drop table gazfond_pn.ISC_MSG$
/
drop table gazfond_pn.ISC_SRV$
/
