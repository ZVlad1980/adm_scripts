begin
dbms_network_acl_admin.append_host_ace(host => '10.1.5.16',ace => sys.xs$ace_type(privilege_list => sys.XS$NAME_LIST('JDWP'), principal_name => 'GAZFOND', principal_type => sys.XS_ACL.PTYPE_DB));
dbms_network_acl_admin.append_host_ace(host => '10.1.5.16',ace => sys.xs$ace_type(privilege_list => sys.XS$NAME_LIST('JDWP'), principal_name => 'GAZFOND_PN', principal_type => sys.XS_ACL.PTYPE_DB));
dbms_network_acl_admin.append_host_ace(host => '10.1.5.16',ace => sys.xs$ace_type(privilege_list => sys.XS$NAME_LIST('JDWP'), principal_name => 'CDM', principal_type => sys.XS_ACL.PTYPE_DB));
dbms_network_acl_admin.append_host_ace(host => '10.1.5.16',ace => sys.xs$ace_type(privilege_list => sys.XS$NAME_LIST('JDWP'), principal_name => 'FND', principal_type => sys.XS_ACL.PTYPE_DB));
dbms_network_acl_admin.append_host_ace(host => '10.1.5.16',ace => sys.xs$ace_type(privilege_list => sys.XS$NAME_LIST('JDWP'), principal_name => 'BSV', principal_type => sys.XS_ACL.PTYPE_DB));

end;
/
grant DEBUG CONNECT SESSION to gazfond, gazfond_pn, cdm, fnd, bsv
/
grant DEBUG ANY PROCEDURE to gazfond, gazfond_pn, cdm, fnd, bsv
/
