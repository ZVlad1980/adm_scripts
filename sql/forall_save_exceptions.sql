procedure renum_namesakes(
    p_namesakes in out nocopy g_namesake_tbl_type
  ) is
    e_forall_error exception;
    pragma exception_init(e_forall_error,-24381);
  begin
    --
    forall i in 1..p_namesakes.count save exceptions
      update people p
      set    p.namesake = p_namesakes(i).namesake
      where  p.fk_contragent = p_namesakes(i).fk_contragent;
    --
  exception
    when e_forall_error then
      for i in 1..sql%bulk_exceptions.count loop
        dbms_output.put('Error: ' || sql%bulk_exceptions(i).error_code);
        dbms_output.put(' / ' || sqlerrm(-sql%bulk_exceptions(i).error_code));
        dbms_output.put(' / ' || p_namesakes(sql%bulk_exceptions(i).error_index).fk_contragent);
        dbms_output.new_line;
      end loop;
    when others then
      fix_exception($$PLSQL_LINE);
      raise;
  end renum_namesakes;
