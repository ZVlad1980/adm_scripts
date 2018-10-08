select uo.status, uo.*
from   user_objects uo
where  1=1
and    uo.OBJECT_TYPE <> 'PACKAGE'
and    uo.OBJECT_NAME in (
         'RPV_POSTREG',
         'FL_MAIN',
         'GAZFOND_STATS',
         'REGPP_PACK',
         'REG_INP_SZ_DELSP',
         'VZNOS_BUH_INFO_TRG'
       )
/*
PACKAGE BODY                             | FL_IMPORT_PKG
PACKAGE BODY                             | FL_MAIN
PACKAGE BODY                             | FL_PACK
PACKAGE BODY                             | FL_TRANSFORM
PACKAGE BODY                             | GAZFOND_STATS
PACKAGE BODY                             | GPBF_PACK
PACKAGE BODY                             | GPB_DATA
PACKAGE BODY                             | REGPP_PACK
PACKAGE BODY                             | TRANSFORM_PACK
PACKAGE BODY                             | VPSK_PACK
PACKAGE BODY                             | VPSK_PACK_MOD
PACKAGE BODY                             | VPSK_TEST
PACKAGE BODY                             | VZNFL_ZACH
PACKAGE BODY                             | VZNUR_ZACH
TRIGGER                                  | DATA_INTO_VPSK
TRIGGER                                  | FL_ZAYAV_TRG
TRIGGER                                  | INS_GPBF_VPSK_TRG
TRIGGER                                  | INS_VZN_UR_TRG
VIEW                                     | VW_FL_BUF
VIEW                                     | VW_FL_CHECK_DOCDONE
VIEW                                     | VW_FL_CHECK_UPDATE
VIEW                                     | VW_FL_DWH_VIP
VIEW                                     | VW_FL_INFO
VIEW                                     | VW_FL_INFO_ARH
VIEW                                     | VW_FL_INFO_FUNC
VIEW                                     | VW_FL_VZNOS_JOIN
VIEW                                     | VW_FL_WEB
VIEW                                     | V_ALL_CONTRIBUTIONS
VIEW                                     | V_NPO_DOGOVOR
VIEW                                     | V_REVENUE



*/
/
begin
  for o in (select uo.OBJECT_TYPE, uo.object_name, uo.status
            from   user_objects uo
            where  1=1
            and    uo.status <> 'VALID'
            and    uo.OBJECT_TYPE <> 'PACKAGE'
            and    uo.OBJECT_NAME in (
                     'RPV_POSTREG',
                     'FL_MAIN',
                     'GAZFOND_STATS',
                     'REGPP_PACK',
                     'REG_INP_SZ_DELSP',
                     'VZNOS_BUH_INFO_TRG'
                   )
            ) loop
    --dbms_output.put_line('alter ' || o.object_type || ' ' || o.object_name || ' compile');
    if o.object_type = 'PACKAGE BODY' then
      execute immediate 'alter package ' || o.object_name || ' compile body';
    else
      execute immediate 'alter ' || o.object_type || ' ' || o.object_name || ' compile';
    end if;
  end loop;
end;
/
/*
alter package AAA_MERGENPO_PKG compile body
/
 grant select on DB_INVALIDS_T to fnd
/
alter MATERIALIZED VIEW V_ADDRESS_FIAS_CITIES compile

*/
