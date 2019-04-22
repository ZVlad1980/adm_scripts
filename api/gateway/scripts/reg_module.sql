declare
  l_module pdh_gateway_module_typ;
begin
  
  logger.set_session(
    p_channels  => logger.GC_CH_OUTPUT,
    p_msg_level => logger.GC_LVL_DEBUG
  );
  
  l_module := pdh_gateway_module_typ(
    p_module_name    => 'ReportGenerator',
    p_action_name    => 'BUILD',
    p_unit_name      => 'REPORT_GENERATOR_PUB',
    p_routine_name   => 'GENERATE_REPORTS',
    p_parameters     => pdh_gateway_params_typ(
      p_parameters => pdh_gateway_param_tbl_typ(
        pdh_gateway_param_typ(p_name => 'P_ROWID_SYSTEM'),
        pdh_gateway_param_typ(p_name => 'P_PRODUCT_TYPE')
      )
    )
  );
    
  pdh_gateway_reg_pkg.add_module(
    p_module      => l_module,
    p_description => 'Exceptions report generator'
  );
end;
