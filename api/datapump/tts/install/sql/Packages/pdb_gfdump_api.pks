create or replace package gfdump_api is

  -- Author  : V.ZHURAVOV
  -- Created : 09.04.2018 9:18:13
  -- Purpose : 
  
  -- Public type declarations
  
  /**
   * Callback ��������� ��������� ������� �����
   *   ������ ��� ����������� ������
   *
   * @param p_handle        - 
   * @param p_schema        - 
   * @param p_metadata_only - 
   *
   */
  procedure config_import_schema$(
    p_handle         number,
    p_schema         varchar2,
    p_metadata_only  boolean
  );
  
  /**
   * ��������� import ��������� ������ ���� �� ������ dpmp
   *
   * @param p_schemas   - ������ ���� (odcivarchar2list)
   * @param p_date_dump - ���� ��������������� ������ (��� ����������� ���� ������)
   * @param p_mode_test - ����� ����� (�������� ������ ����������, �������� ������ �����������)
   * @param p_continue  - ���� ����������� ��������. ������������ ��� �������, ���������� ����������
   *
   */
  procedure import(
    p_schemas   sys.odcivarchar2list,
    p_date_dump date,
    p_mode_test boolean default false,
    p_continue  boolean default false
  );
  
end gfdump_api;
/
