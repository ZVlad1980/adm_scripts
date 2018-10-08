create or replace package body gf_dump_log_api is

  type gt_message_rec is record (
    message_type varchar2(10),
    message      varchar2(2000),
    error_code   number,
    error_detail clob
  );
  type gt_messages_tbl is table of gt_message_rec;

  g_messages gt_messages_tbl;

  -- Private type declarations
  procedure init is
  begin
    g_messages := gt_messages_tbl();
  end init;
  
  procedure append_message(
   p_message_type varchar2,
   p_message      varchar2
  ) is
  begin
    if g_messages is null then init; end if;
    
    g_messages.extend(1);
    g_messages(g_messages.count).message_type := p_message_type;
    g_messages(g_messages.count).message      := p_message;
    
    if p_message_type in (GC_MSG_ERROR, GC_MSG_WARNING) then
      dbms_lob.createtemporary(g_messages(g_messages.count).error_detail, false);
      --
      dbms_lob.append(
        g_messages(g_messages.count).error_detail,
        'Error stack:'
      );
      dbms_lob.append(
        g_messages(g_messages.count).error_detail,
        dbms_utility.format_error_stack
      );
      --
      dbms_lob.append(
        g_messages(g_messages.count).error_detail,
        'Error backtrace:'
      );
      dbms_lob.append(
        g_messages(g_messages.count).error_detail,
        dbms_utility.format_error_backtrace
      );
      --
      dbms_lob.append(
        g_messages(g_messages.count).error_detail,
        dbms_utility.format_call_stack
      );
      
      g_messages(g_messages.count).error_code := sqlcode;
    end if;
    
    if g_messages.count > 100 then
      fix_messages;
    end if;
    
  end append_message;
  
  procedure append_error(
    p_message varchar2
  ) is
  begin
    append_message(
      p_message_type => GC_MSG_ERROR,
      p_message      => p_message
    );
  end append_error;
  
  procedure append_warning(
    p_message varchar2
  ) is
  begin
    append_message(
      p_message_type => GC_MSG_WARNING,
      p_message      => p_message
    );
  end append_warning;
  
  procedure append_message(
    p_message varchar2
  ) is
  begin
    append_message(
      p_message_type => GC_MSG_MESSAGE,
      p_message      => p_message
    );
  end append_message;
  
  procedure fix_messages is
    pragma autonomous_transaction;
  begin
    forall i in 1..g_messages.count
      insert into gf_dump_log_t(
        message_type,
        message,
        error_code,
        error_detail
      ) values (
        g_messages(i).message_type,
        g_messages(i).message,
        g_messages(i).error_code,
        g_messages(i).error_detail
      );
    commit;
    init;
  exception
    when others then
      rollback;
      raise;
  end fix_messages;
  
  function get_error_detail return clob is
  begin
    --
    for i in 1..g_messages.count loop
      if g_messages(i).message_type in (GC_MSG_ERROR, GC_MSG_WARNING) then
        return g_messages(i).error_detail;
      end if;
    end loop;
    --
    return null;
  end get_error_detail;
  
  procedure show_messages is
  begin
    for i in 1..g_messages.count loop
      dbms_output.put_line(
        g_messages(i).message_type || ' / ' ||
        g_messages(i).message      || ' / ' ||
        g_messages(i).error_code   || ' / ' ||
        g_messages(i).error_detail
      );
    end loop;
  end show_messages;
  
end gf_dump_log_api;
/
