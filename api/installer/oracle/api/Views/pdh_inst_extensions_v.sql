create or replace view pdh_inst_extensions_v as
  with w_extensions as (
    select t.instance_name, t.ext_version, t.ext_code
    from   table(pdh_inst_auxiliary_api.get_extensions(sys.odcivarchar2list(
             'pdh_dev',
             'pdh_pdev',
             'pdh_qa',
             'pdh_uat',
             'pdh_sit',
             'pdh_perf',
             'pdh_ppd',
             'pdh_prod'
           ))) t
  )
  select *
  from   w_extensions
  pivot(
    max(ext_version)
    for instance_name in (
           'pdh_dev',
           'pdh_pdev',
           'pdh_qa',
           'pdh_uat',
           'pdh_sit',
           'pdh_perf',
           'pdh_ppd',
           'pdh_prod'
      )
  )
/
