grant execute on dbms_lock to inf;
grant execute on dbms_lock to inf_pn;
grant execute on dbms_lock to gazfond;
grant execute on dbms_lock to gazfond_pn;
grant execute on dbms_lock to fnd;
grant execute on dbms_lock to cdm;
grant select on v_$session to gazfond, gazfond_pn, cdm;
exit;