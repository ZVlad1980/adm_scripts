/*
DWHDATA,FONDDATA,FONDINDX,USERDATA,WEBDATA,ARHDATA,MDMDATA,OPSDATA,INFDATA,GFNDINDX,CTXDATA,MDMDAT2,FIASDATA,GFNDDAT2,GFPNDATA,GFPNINDX,SMPPDATA
*/
/*
begin
  dbms_tts.transport_set_check(
    'DWHDATA,FONDDATA,FONDINDX,USERDATA,WEBDATA,ARHDATA,MDMDATA,OPSDATA,INFDATA,GFNDINDX,CTXDATA,MDMDAT2,FIASDATA,GFNDDAT2,GFPNDATA,GFPNINDX,SMPPDATA',
    true
  );
end;
*/
select *
from   sys.transport_set_violations
/
select *
from   all_constraints c
where  c.CONSTRAINT_NAME = 'ISC_MSG_SRV_FK'
--and    c.OWNER = 'GAZFOND'
--gazfond.ISC_MSG
/
select *
from   all_indexes ai
where  ai.owner = 'FND'
and    ai.index_name IN ('IDX_NUM_VAL')
/
--fnd.IZM_KEY_VAL
