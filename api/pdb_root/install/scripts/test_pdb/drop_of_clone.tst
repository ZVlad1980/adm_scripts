PL/SQL Developer Test script 3.0
19
-- Created on 11.05.2018 by V.ZHURAVOV 
declare 
  -- Local variables here
  i integer;
begin
  --dbms_session.reset_package; return;
  -- Test statements here
  for p in (
    select c.id, c.pdb_name
    from   pdb_clones_t c
    where  c.pdb_name in ('VBZ_TSTDB', 'VBZ_TSTDB_01')
    order by c.pdb_created desc
  ) loop
    pdb_api.action(
      p_action      => pdb_api.GC_ACT_DROP,
      p_pdb_name    => p.pdb_name--,      p_planned_at  => to_date('20180519001000', 'yyyymmddhh24miss')
    );
  end loop;
end;
0
0
