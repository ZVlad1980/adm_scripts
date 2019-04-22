create or replace package pdh_inst_extensions_def is

  -- Author  : VZHURAVOV
  -- Created : 1/9/2019 3:47:45 PM
  -- Purpose : Defaines of API PDH Installer
  
  -- Public type declarations
  
  --Extension's Properties
  C_EP_VERSION    constant varchar2(40) := 'VERSION';
  C_EP_COMMIT_SHA constant varchar2(40) := 'COMMIT_SHA';

end pdh_inst_extensions_def;
/
