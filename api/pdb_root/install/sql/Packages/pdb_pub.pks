create or replace package pdb_pub is

  -- Author  : V.ZHURAVOV
  -- Created : 29.04.2018 14:43:23
  -- Purpose : обвертка дл€ PDB_API
  
  GC_RFR_NO           constant varchar2(20) := 'NO';             --не обновл€ть
  GC_RFR_DAILY        constant varchar2(20) := 'DAILY';          --ежедневное обновление
  GC_RFR_PARENT       constant varchar2(20) := 'UPDATE_PARENT';  --обновление после обновлени€ родительского контейнера (т.е. клон будет пересоздан, после обновлени€ родител€)
  
  GC_FRZ_YES          constant varchar2(20) := 'YES';
  GC_FRZ_NO           constant varchar2(20) := 'NO';
  
  /**
   * ѕроцедура clone - создание клона PDB_NODE
   * 
   * p_creator     - им€ создател€
   * p_pdb_name    - им€ создаваемого клона
   * p_pdb_parent  - им€ PDB-источника
   *
   *  ≈сли p_refreshable или p_freeze отличны от дефолтных значений - событие не будет поставлено в очередь, но
   *    в таблице PDB_CLONES_T будет содана запись о новом клоне, который, в свою очередь, 
   *    будет создан при очередном обслуживании Ѕƒ
   */
  procedure clone(
    p_creator      varchar2,
    p_pdb_name     varchar2,
    p_pdb_parent   varchar2
  );
  
  /**
   * ѕроцедура clone - создание клона PDB_NODE
   * 
   * p_creator     - им€ создател€
   * p_pdb_name    - им€ создаваемого клона
   * p_pdb_parent  - им€ PDB-источника
   * p_refreshable - режим обновлени€ 
   * p_freeze      - заморозка клона
   *
   *  ≈сли p_refreshable или p_freeze отличны от дефолтных значений - событие не будет поставлено в очередь, но
   *    в таблице PDB_CLONES_T будет содана запись о новом клоне, который, в свою очередь, 
   *    будет создан при очередном обслуживании Ѕƒ
   */
  procedure clone(
    p_creator      varchar2,
    p_pdb_name     varchar2,
    p_pdb_parent   varchar2,
    p_refreshable  varchar2,
    p_freeze       varchar2
  );
  
  procedure open_(
    p_pdb_name varchar2
  );
  
  procedure open_ro_(
    p_pdb_name varchar2
  );
  
  procedure close_(
    p_pdb_name varchar2
  );
  
  procedure freeze_(
    p_pdb_name varchar2
  );
  
  procedure unfreeze_(
    p_pdb_name varchar2
  );
  
  /**
   * ѕроцедура set_refreshable - устанавливает режим обновлени€ клона
   * 
   * p_pdb_name - им€ PDB
   * p_refresh  - режим обновлени€, см. выше константы GC_PFR
   *
   */
  procedure set_refreshable(
    p_pdb_name varchar2,
    p_refresh  varchar2
  );
  
  /**
   * ѕроцедура request_drop пометит PDB дл€ удалени€, т.е. снимет заморозку и сделает клон не обновл€емым
   *   —амо удаление будет выполнено при обслуживании Ѕƒ
   */
  procedure request_drop(
    p_pdb_name varchar2
  );
  
end pdb_pub;
/
