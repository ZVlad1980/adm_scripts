declare
  l_arr sys.odcinumberlist := 
        sys.odcinumberlist(
          1, 2, 2
        );
  l_result number;
  function get_parity(p_num number) return number is
  begin
    return case mod(p_num, 2) when 0 then 1 else -1 end;
  end;
begin
  l_result := get_parity(l_arr(1));
  for i in 2..l_arr.count loop
    --
    if get_parity(l_arr(i) <> sign(l_result) then
      if  then
      end if;
    end if;
    --
  end loop;
  --
  dbms_output.put_line('Все числа ' || case sign(l_result) when 1 then 'Нечетные' else 'Четные' end || ', кроме элемента с индексом ' || trunc(l_result) || ' = ' || l_arr(trunc(l_result)));
  --
end;
