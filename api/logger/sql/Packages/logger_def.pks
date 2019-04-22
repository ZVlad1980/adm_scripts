create or replace package logger_def is

  -- Author  : Zhuravov
  -- Created : 12/7/2018 9:14:06 AM
  -- Purpose : Defines constants and types of API Logger
  
  GC_LVL_DEBUG      constant integer := 1;
  GC_LVL_INFO       constant integer := 2;
  GC_LVL_WARNING    constant integer := 3;
  GC_LVL_ERROR      constant integer := 4;
  
  GC_CH_LOG      constant integer := 1;
  GC_CH_OUTPUT   constant integer := 2;
  GC_CH_BOTH     constant integer := 3;
  
  GC_FMT_DATE       constant varchar2(20) := 'MM/DD/YYYY';
  GC_FMT_DATE_FULL  constant varchar2(40) := 'MM/DD/YYYY HH24:MI:SS';
  
  GC_ST_SUCCESS     constant number       := 0;
  GC_ST_WARNING     constant number       := 1;
  GC_ST_ERROR       constant number       := 2;
  
  new_line   varchar2(1)  := chr(10);
  delim_line varchar2(30) := rpad('-', 30, '-');
end logger_def;
/
