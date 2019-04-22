PL/SQL Developer Test script 3.0
26
-- Created on 11/30/2018 by VZHURAVOV 
declare 
  -- Local variables here
  l_unit   pdh_gateway_unit_typ;
  l_params pdh_gateway_params_typ;
  l_json   varchar2(32767);
begin
  
  l_json := '{
	"P_ROWID_SOURCE": "WCR",
	"P_PRODUCT_TYPE": "ARTICLE"
}';
  -- Test statements here
  l_unit   := pdh_gateway_unit_typ(
    p_unit_name      => 'ReportGenerator',
    p_action         => 'Action',
    p_owner          => user,
    p_package_name   => 'REPORT_GENERATOR_PUB',
    p_procedure_name => 'GENERATE_REPORTS',
    p_parameters     => pdh_gateway_params_typ(null)
  );
  l_params := pdh_gateway_params_typ(null);
  
  dbms_output.put_line(l_unit.get_launch_cmd(l_params));
  
end;
0
0
