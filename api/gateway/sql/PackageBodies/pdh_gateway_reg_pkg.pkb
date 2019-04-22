create or replace package body pdh_gateway_reg_pkg is

  C_MODULE constant varchar2(30) := 'PDH_GATEWAY';
  
  /**
   * Check exists registered of module, if yes - set p_module.module_id
   *  Return boolean
   */
  function exists_module(
    p_module    in out nocopy pdh_gateway_module_typ
  ) return boolean is
    c_routine constant varchar2(30) := 'exists_module';
    
  begin
    logger.start_action(c_routine);
    
    select m.id
    into   p_module.module_id
    from   pdh_gateway_modules_t m
    where  m.module_name = p_module.module_name;
    
    logger.end_action;
    
    return true;
  
  exception
    when no_data_found then
      logger.out('Module ' || p_module.module_name || ' not found');
      return false;
    when others then
      logger.fail_action(
        p_unit    => $$PLSQL_UNIT,
        p_routine => c_routine,
        p_line    => $$PLSQL_LINE
      );
      raise;
  end exists_module;
  
  /**
   * Check exists registered of action of module, if yes - set p_module.action_id
   *  Return boolean
   */
  function exists_action(
    p_module    in out nocopy pdh_gateway_module_typ
  ) return boolean is
    c_routine constant varchar2(30) := 'exists_module';
    
  begin
    logger.start_action(c_routine);
    
    select a.id
    into   p_module.action_id
    from   pdh_gateway_actions_t a
    where  1=1
    and    a.action_name = p_module.action_name
    and    a.fk_module_id = p_module.module_id;
    
    logger.end_action;
    
    return true;
  
  exception
    when no_data_found then
      logger.out('Action ' || p_module.action_name || ' of module ' || p_module.module_name || ' (' || p_module.module_id || ') not found');
      return false;
    when others then
      logger.fail_action(
        p_unit    => $$PLSQL_UNIT,
        p_routine => c_routine,
        p_line    => $$PLSQL_LINE
      );
      raise;
  end exists_action;
  
  /**
   * Procedure merge_module register of module, if already exists - update data of module
   */
  procedure merge_module(
    p_module    in out nocopy pdh_gateway_module_typ,
    p_description pdh_gateway_modules_t.description%type
  ) is
    c_routine constant varchar2(30) := 'merge_module';
  begin
    
    logger.start_action(c_routine);
        
    if exists_module(p_module) then
      update pdh_gateway_modules_t m
      set    m.description = nvl(p_description, m.description)
      where  nvl(m.description, '#NULL#') <> nvl(p_description, '#NULL#')
      and    m.id = p_module.module_id;
    else
      insert into pdh_gateway_modules_t(
        id,
        module_name,
        created_at,
        description
      ) values (
        pdh_gateway_modules_seq.nextval,
        p_module.module_name,
        sysdate,
        p_description
      ) returning id into p_module.module_id;
    end if;
    
    logger.end_action;
  
  exception
    when others then
      logger.fail_action(
        p_unit    => $$PLSQL_UNIT,
        p_routine => c_routine,
        p_line    => $$PLSQL_LINE
      );
      raise;
  end merge_module;
  
  /**
   * Procedure merge_action register of action of module, if already exists - update data of action
   */
  procedure merge_action(
    p_module    in out nocopy pdh_gateway_module_typ
  ) is
    c_routine constant varchar2(30) := 'merge_action';
    
  begin
    logger.start_action(
      c_routine
    );
    
    if exists_action(p_module) then
      update pdh_gateway_actions_t a
      set    a.action_name   = p_module.action_name      ,
             a.owner         = nvl(p_module.owner, user) ,
             a.unit_name     = p_module.unit_name        ,
             a.routine_name  = p_module.routine_name
      where  a.id = p_module.action_id;
    else
      insert into pdh_gateway_actions_t(
        id,
        fk_module_id,
        action_name,
        owner,
        unit_name,
        routine_name,
        created_at
      ) values (
        pdh_gateway_actions_seq.nextval,
        p_module.module_id,
        p_module.action_name ,
        nvl(p_module.owner, user),
        p_module.unit_name ,
        p_module.routine_name ,
        sysdate
      ) returning id into p_module.action_id;
    end if;
    
    logger.end_action;
  exception
    when others then
      logger.fail_action(
        p_unit    => $$PLSQL_UNIT,
        p_routine => c_routine,
        p_line    => $$PLSQL_LINE
      );
      raise;
  end merge_action;
  
  /**
   * Procedure merge_parameters create or update parameters of action of module
   */
  procedure merge_parameters(
    p_action_id     pdh_gateway_actions_t.id%type,
    p_parameters    pdh_gateway_param_tbl_typ
  ) is
    c_routine constant varchar2(30) := 'merge_parameters';
    
  begin
    logger.start_action(c_routine);
    
    merge into pdh_gateway_parameters_t p
    using (select p_action_id      fk_action_id,
                  p.parameter_name
           from   table(p_parameters) p
          ) u
    on    (p.fk_action_id = u.fk_action_id and p.parameter_name = u.parameter_name)
    when not matched then
      insert(id, fk_action_id, parameter_name)
      values(pdh_gateway_parameters_seq.nextval, u.fk_action_id, u.parameter_name)
    ;
    
    logger.end_action;
  exception
    when others then
      logger.fail_action(
        p_unit    => $$PLSQL_UNIT,
        p_routine => c_routine,
        p_line    => $$PLSQL_LINE
      );
      raise;
  end merge_parameters;
  
  /**
   * Procedure add_module put the data of module into tables of API Gateway
   *   If module exists - procedure modify data of module
   */
  procedure add_module(
    p_module      in out nocopy pdh_gateway_module_typ,
    p_description pdh_gateway_modules_t.description%type default null,
    p_commit      boolean default false
  ) is
    c_routine constant varchar2(30) := 'add_module';
    
  begin
    
    logger.start_module(
      C_MODULE,
      c_routine
    );
    merge_module(
      p_module      => p_module,
      p_description => p_description
    );
    
    merge_action(
      p_module      => p_module
    );
    
    merge_parameters(
      p_action_id   => p_module.action_id,
      p_parameters  => p_module.get_param_tbl
    );
    
    if p_commit then
      commit;
    end if;
    
    logger.end_module;
  exception
    when others then
      logger.error(
        p_msg     => 'Add module failed',
        p_unit    => $$PLSQL_UNIT,
        p_routine => c_routine,
        p_line    => $$PLSQL_LINE
      );
      logger.end_module;
      
      if p_commit then
        rollback;
      end if;
      
      raise_application_error(-20000, logger.get_last_error);
  end add_module;

end pdh_gateway_reg_pkg;
/
