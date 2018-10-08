/*
create table drop_indexes(
        owner      varchar2(32),
        table_name varchar2(32),
        index_name varchar2(32),
        cmd        varchar2(4000)
      )
*/
declare
  --
  C_MODE  constant varchar2(20) := 'enable'; --enable --disable
  C_OWNER constant varchar2(32) := 'GAZFOND';
  --
  l_cnt   int;
  --
  l_tables sys.odcivarchar2list;
  --
  cursor c_constraints(p_table_name varchar2, p_type varchar2) is
    select c.table_name, c.constraint_name
    from   all_constraints c
    where  c.status <> upper(C_MODE || 'd')
    and    c.constraint_type = case when p_type = 'A' and c.constraint_type = 'R' then 'A' when p_type = 'A' then c.constraint_type else p_type end
    and    c.table_name = p_table_name
    and    c.owner = C_OWNER;
  --
  cursor c_indexes(p_table_name varchar2, p_status varchar2) is
    select ai.index_name
    from   all_indexes ai
    where  1=1
    and    ai.status = p_status
    and    ai.uniqueness = 'UNIQUE'
    and    ai.table_name = p_table_name
    and    ai.owner = C_OWNER;
  --
  procedure ei(p_cmd varchar2) is
  begin
    --dbms_output.put(rpad(p_cmd || ' ', 80, '.') || ' ');
    execute immediate p_cmd;
    --dbms_output.put_line('Ok');
  exception
    when others then
      dbms_output.put_line(p_cmd || chr(10) || 'Error: ' || chr(10) || sqlerrm);
  end;
  --
  procedure change_constraints_(p_table_name varchar2, p_mode varchar2, p_type varchar2 default 'A') is
  begin
    for c in c_constraints(p_table_name, p_type) loop
      ei('alter table ' || C_OWNER || '.' || p_table_name || ' ' || C_MODE || ' constraint ' || c.constraint_name);
    end loop;
  end change_constraints_;
  --
  procedure drop_indexes_(p_table_name varchar2) is
    --
    procedure save_index_ddl_(p_index_name varchar2) is
      l_dummy number;
    begin
      select 1
      into   l_dummy
      from   drop_indexes d
      where  1=1
      and    d.index_name = p_index_name
      and    d.table_name = p_table_name
      and    d.owner = C_OWNER;
    exception
      when no_data_found then
        insert into drop_indexes(
          owner,
          table_name,
          index_name,
          cmd
        ) values(
          C_OWNER,
          p_table_name,
          p_index_name,
          dbms_metadata.get_ddl('INDEX', p_index_name, C_OWNER)
        );
    end save_index_ddl_;
  begin
    --
    for i in c_indexes(p_table_name, 'VALID') loop
      save_index_ddl_(i.index_name);
      ei('drop index ' || C_OWNER || '.' || i.index_name);
    end loop;
  end drop_indexes_;
  --
  procedure create_indexes_(p_table_name varchar2) is
  begin
    for i in (select d.cmd
              from   drop_indexes d
              where  1=1
              and    not exists (
                       select 1
                       from   all_indexes ai
                       where  ai.owner = d.owner
                       and    ai.table_name = ai.table_name
                       and    ai.index_name = d.index_name
                     )
              and    d.owner = C_OWNER
              and    d.table_name = p_table_name) loop
      ei(i.cmd);
    end loop;
  end;
  --
  procedure stop_jobs_ is
    cursor l_jobs_cur is
      select s.owner, s.job_name
      from   all_scheduler_jobs s
      where  s.enabled = 'TRUE';
  begin
    for job in l_jobs_cur loop
      dbms_output.put(job.owner || '.' || job.job_name || ' ');
      begin
        dbms_scheduler.disable(name => job.owner || '.' || job.job_name, force => true);
        dbms_output.put_line('Ok');
      exception
      when others then
        dbms_output.put_line('Error: ' || sqlerrm);
      end;
    end loop;
  end stop_jobs_;
begin
  --
  if substr(user, 1,3) <> 'SYS' then
    dbms_output.put_line('Run only SYS or SYSTEM! (current: ' || user || ')');
    raise program_error;
  end if;
  --
  select t.table_name
  bulk collect into l_tables
  from   all_tables t
  where  1=1
  and    t.table_name <> 'PEOPLE' --PEOPLE не обрабатываем, чтобы не включить direct_path при загрузке, надо грузить через extrnal_table
  and    t.owner = C_OWNER
  order by t.table_name;
  --
  dbms_output.put_line(initcap(lower(C_MODE)) || ' all constraints, triggers and drop indexes of tables ' || C_OWNER || ': ' || l_tables.count);
  --
  for i in 1..l_tables.count loop
    ei('alter table ' || C_OWNER || '.' || l_tables(i) || ' ' || C_MODE || ' all triggers');
    if C_MODE = 'disable' then
      change_constraints_(l_tables(i), C_MODE, 'R');
    else
      create_indexes_(l_tables(i));
      change_constraints_(l_tables(i), C_MODE);
    end if;
  end loop;
  
  for i in 1..l_tables.count loop
    if C_MODE = 'disable' then
      change_constraints_(l_tables(i), C_MODE);
      drop_indexes_(l_tables(i));
    else
      null;
      --change_constraints_(t.table_name, C_MODE, 'R');
    end if;
  end loop;
  --
  stop_jobs_;
  --
  dbms_output.put_line('Process complete: ' || l_tables.count || ' tables.');
  --
end;
/
