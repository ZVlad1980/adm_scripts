PL/SQL Developer Test script 3.0
18
-- Created on 11/30/2018 by VZHURAVOV 
declare 
  -- Local variables here
  i integer;
begin
  -- Test statements here
  logger.set_session(
    p_channels  => logger.GC_CH_BOTH,
    p_msg_level => logger.GC_LVL_DEBUG
  );
  /*pdh_gateway_pkg.launch(
    p_module => 'ReportGenerator',
    p_action => 'Build',
    p_json   => '{"P_ROWID_SYSTEM": "JANIS","P_PRODUCT_TYPE": "JOURNAL"}'
  );*/
  pdh_gateway_pkg.launch('ReportGenerator', 'BUILD', '{"P_ROWID_SYSTEM": "JANIS","P_PRODUCT_TYPE": "ARTICLE"}');
  
end;
0
0
