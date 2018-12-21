begin
  SYS.kill_session(pn_sid => 971, pn_serial => 32231);
end;
/
/*
CREATE OR REPLACE PROCEDURE SYS.kill_session(pn_sid NUMBER, pn_serial NUMBER)
AS
    lv_user   VARCHAR2(30);
BEGIN
    SELECT username
      INTO lv_user
      FROM v$session
     WHERE sid = pn_sid AND serial# = pn_serial;

    IF  lv_user NOT IN ('SYS', 'SYSTEM')
    THEN
        EXECUTE IMMEDIATE   'alter system kill session '''
                         || pn_sid
                         || ','
                         || pn_serial
                         || '''';
    ELSE
        raise_application_error(
            -20000,
            'Attempt to kill protected system session has been blocked.');
    END IF;
END;

*/
