create or replace package pdb_daemon_api is

  -- Author  : V.ZHURAVOV
  -- Created : 20.04.2018 10:35:54
  -- Purpose : 
  --GC_PDB_NOTFOUND   constant varchar2(15) := 'NOT_FOUND';
  
  function scn_to_date(p_scn number) return date;
  
  procedure start_daemon;
  
  procedure stop_daemon;
  
end pdb_daemon_api;
/
