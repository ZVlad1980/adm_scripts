declare
  l_version pdh_inst_extensions_t.ext_version%type := '&1';
begin
  pdh_inst_extensions_pub.register(
    p_extension => 'PDH_INSTALL',
    p_ext_descr => 'API of PDH Installer',
    p_version   => l_version
  );
  pdh_inst_extensions_pub.set_version(
    p_extension  => 'PDH_INSTALL',
    p_version    => l_version,
    p_commit_sha => null
  );
  commit;
end;
/
