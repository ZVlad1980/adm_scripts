begin
  pdh_inst_extensions_pub.register(
    p_extension => 'PDH_LOGGER',
    p_ext_descr => 'API PDH Logger'
  );                                     
  commit;
end;
/