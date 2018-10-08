create or replace trigger pdb_actions_au_trg
  after update
  on pdb_actions_t 
  referencing old as old new as new
  for each row
declare
  procedure purge_clone_ is
  begin
    delete from pdb_clones_t c
    where  c.pdb_name = (
             select c.pdb_name
             from   pdb_clones_v c
             where  c.pdb_name = :new.pdb_name
             and    c.refreshable = 'NO'
             and    c.freeze = 'NO'
           );
  exception
    when others then
      null;
  end;
begin
  if :new.action = 'DROP' and :new.status = 'SUCCESS' then
    purge_clone_;
  end if;
end pdb_actions_au_trg;
/
