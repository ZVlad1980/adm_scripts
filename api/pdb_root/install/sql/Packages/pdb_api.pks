create or replace package pdb_api is

  -- Author  : V.ZHURAVOV
  -- Created : 29.04.2018 12:40:41
  -- Purpose : 
  
  GC_ACT_CLONE        constant varchar2(32) := 'CLONE';
  GC_ACT_CLOSE        constant varchar2(32) := 'CLOSE';
  GC_ACT_OPEN         constant varchar2(32) := 'OPEN';
  GC_ACT_OPEN_RO      constant varchar2(32) := 'OPEN_RO';
  GC_ACT_DROP         constant varchar2(32) := 'DROP';
  
  GC_RFR_NO           constant varchar2(20) := 'NO';
  GC_RFR_DAILY        constant varchar2(20) := 'DAILY';
  GC_RFR_PARENT       constant varchar2(20) := 'UPDATE_PARENT';
  
  GC_FRZ_YES          constant varchar2(20) := 'YES';
  GC_FRZ_NO           constant varchar2(20) := 'NO';
  
  GC_RFSH_DROP         constant varchar2(32) := 'DROP';
  GC_RFSH_CREATE       constant varchar2(32) := 'CREATE';
  GC_RFSH_RESTORE_MODE constant varchar2(32) := 'RESTORE_MODE';
  
  e_action_rejected   exception;
  
  procedure update_clone(
    p_clone_row pdb_clones_v%rowtype
  );
  
  procedure get_clone_row(
    p_clone_row in out nocopy pdb_clones_v%rowtype
  );
  
  /**
   * ѕроцедура add_database добавл€ет описание реальной Ѕƒ в PDB_NODE.PDB_CLONES_T
   *   и создает базовый клон
   *
   * p_pdb_name          - им€ Ѕƒ
   * p_clone_name        - им€ базового клона
   * p_acfs_path         - путь к точке монтировани€ ACFS, в корне д.б. директори€ с созданной PDB
   *
   */
  procedure add_database(
    p_pdb_name          varchar2,
    p_clone_name        varchar2,
    p_acfs_path         varchar2
  );
  
  /**
   * ѕроцедура обработки событий (постановка в очередь, ведение списка клонов)
   *
   * p_action      - код событи€ (GC_ACT...)
   * p_pdb_name    - им€ PDB
   * p_pdb_parent  - им€ родител€ (по умолчанию - DEFAULT PARENT из pdb_clones_t)
   * p_creator     - им€ создател€ (по умолчанию USER)
   * p_planned_at  - планируема€ дата выполнени€ событи€
   * p_refreshable - режим обновлени€ (актуален только при создании клона)
   * p_freeze      - заморозка клона (актуален только при создании клона)
   *
   *  ≈сли p_refreshable или p_freeze отличны от NO - событие не будет добавлено в очередь, а
   *    в таблице PDB_CLONES_T будет содана запись о новом клоне, который будет создан при очередном обслуживании Ѕƒ 
   *    (планируетс€ раз в сутки)
   */
  procedure action(
    p_action       varchar2,
    p_pdb_name     varchar2,
    p_pdb_parent   varchar2 default null,
    p_creator      varchar2 default user,
    p_planned_at   date     default null,
    p_refreshable  varchar2 default GC_RFR_NO,
    p_freeze       varchar2 default GC_FRZ_NO
  );
  
  procedure refresh_pdbs(
    p_action     varchar2,
    p_planned_at date    default sysdate,
    p_synch_mode boolean default false
  );
  
  procedure restore_open_mode;
  
  procedure recreate_pdbs(
    p_pdb_node varchar2
  );
  
end pdb_api;
/
