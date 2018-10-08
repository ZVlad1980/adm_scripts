create or replace trigger pdb_clones_biu_trg
  before insert or update
  on pdb_clones_t 
  referencing old as old new as new
  for each row
declare
  -- local variables here
begin
  :new.updated_at := systimestamp;
end pdb_clones_biu_trg;
/
