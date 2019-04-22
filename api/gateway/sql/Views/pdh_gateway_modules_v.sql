create or replace view pdh_gateway_modules_v as
  select m.id           fk_module_id,
         m.module_name,
         a.id           fk_action_id,
         a.action_name,
         pdh_gateway_module_typ(
           p_module_name    => m.module_name,
           p_action_name    => a.action_name,
           p_owner          => a.owner,
           p_unit_name      => a.unit_name,
           p_routine_name   => a.routine_name,
           p_parameters     => pdh_gateway_params_typ(
             p_parameters => cast(multiset(
               select pdh_gateway_param_typ(p_name => p.parameter_name)
               from   pdh_gateway_parameters_t p
               where  p.fk_action_id = a.id
               order by p.id
             ) as pdh_gateway_param_tbl_typ)
           )
         ) module
  from   pdh_gateway_modules_t m,
         pdh_gateway_actions_t a
  where  m.id = a.fk_module_id
/
