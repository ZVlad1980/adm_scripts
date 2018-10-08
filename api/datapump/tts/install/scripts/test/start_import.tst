PL/SQL Developer Test script 3.0
18
-- Created on 09.04.2018 by V.ZHURAVOV 
declare 
begin
  -- Test statements here
  --dbms_session.reset_package; return;
  gfdump_api.import(
    p_schemas   => sys.odcivarchar2list(
                     'CDM'/*,
                     --'FND'/*,
                     'GAZFOND_PN',
                     'GAZFOND'--*/
                   ),
    p_date_dump => to_date(180522, 'yymmdd'),
    p_mode_test => true
    --,p_continue => true
  );
  
end;
0
0
