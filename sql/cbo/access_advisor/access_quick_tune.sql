declare
  t_name varchar2(255) := 'MY_QUICKTUNE_TASK';
  sq     varchar2(4000) := 'SELECT COUNT(*) FROM customers WHERE cust_state_province =''CA''';
begin
  dbms_advisor.quick_tune(dbms_advisor.sqlaccess_advisor, t_name, sq);
end;
/
declare
in_task_name varchar2(32) := 'MY_QUICKTUNE_TASK';
  cursor curs is
    select distinct action_id,
                    command,
                    attr1,
                    attr2,
                    attr3,
                    attr4
    from   user_advisor_actions
    where  task_name = in_task_name
    order  by action_id;
  v_action  number;
  v_command varchar2(32);
  v_attr1   varchar2(4000);
  v_attr2   varchar2(4000);
  v_attr3   varchar2(4000);
  v_attr4   varchar2(4000);
  v_attr5   varchar2(4000);
begin
  open curs;
  dbms_output.put_line('=========================================');
  dbms_output.put_line('Task_name = ' || in_task_name);
  loop
    fetch curs
      into v_action,
           v_command,
           v_attr1,
           v_attr2,
           v_attr3,
           v_attr4;
    exit when curs%notfound;
    dbms_output.put_line('Action ID: ' || v_action);
    dbms_output.put_line('Command : ' || v_command);
    dbms_output.put_line('Attr1 (name)      : ' || substr(v_attr1, 1, 30));
    dbms_output.put_line('Attr2 (tablespace): ' || substr(v_attr2, 1, 30));
    dbms_output.put_line('Attr3             : ' || substr(v_attr3, 1, 30));
    dbms_output.put_line('Attr4             : ' || v_attr4);
    dbms_output.put_line('Attr5             : ' || v_attr5);
    dbms_output.put_line('----------------------------------------');
  end loop;
  close curs;
  dbms_output.put_line('=========END RECOMMENDATIONS============');
end show_recm;
/
--SYS!!!
CREATE or REPLACE DIRECTORY ADVISOR_RESULTS AS '/home/oracle/projects/oracle/advisor';
GRANT READ ON DIRECTORY ADVISOR_RESULTS TO PUBLIC;
GRANT WRITE ON DIRECTORY ADVISOR_RESULTS TO PUBLIC;
--
begin
  DBMS_ADVISOR.CREATE_FILE(DBMS_ADVISOR.GET_TASK_SCRIPT('MY_QUICKTUNE_TASK'), 'ADVISOR_RESULTS', 'adv_acc_quick.sql');
end;
