begin
  pdh_inst_extensions_pub.register(
    p_extension => 'PDH_GATEWAY',
    p_ext_descr => 'API PDH Gateway'
  );                                     
  commit;
end;
/