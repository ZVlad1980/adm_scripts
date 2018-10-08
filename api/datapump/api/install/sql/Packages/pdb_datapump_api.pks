create or replace package datapump_api is

  -- Author  : V.ZHURAVOV
  -- Created : 09.04.2018 11:23:27
  -- Purpose : 
  
  -- Public type declarations
  
  /**
   * ��������� ���������� ��������� ����������� remap_tablespace
   *
   * @param p_handle    - ��������� �� datapump �������
   * @param p_source_ts - ��� ��������� ����.������������
   * @param p_target_ts - ��� �������� ����.������������
   *
   */
  procedure remap_tablespace(
    p_handle        number,
    p_source_ts     varchar2,
    p_target_ts     varchar2
  );
  
  /**
   * ��������� ���������� �������� ������ ������� exclude_table_data
   *
   * @param p_handle     - ��������� �� datapump �������
   * @param p_schema     - ��� �����
   * @param p_table_name - ��� �������
   *
   */
  procedure exclude_table_data(
    p_handle        number,
    p_schema        varchar2,
    p_table_name    varchar2
  );
  
  /**
   * ��������� ������� ����� import_schema
   *
   * @param p_master_table  - ��� ������ �������
   * @param p_schema        - ��� �����
   * @param p_directory     - ��� ������� DIRECTORY
   * @param p_dump_file     - ��� dump ����� (��� ������)
   * @param p_log_file      - ��� ��� ����� (����� � DIRECTORY)
   * @param p_config_fn     - ������� ��� ��������� �������, ������ ��������� ��� ���������: p_handle number, p_schema varchar2, p_metadata_only boolean
   * @param p_only_user     - ������� �������� ������ ����������� ����� (p_config_fn �� ����������!)
   * @param p_metadata_only - ������� �������� ������ ����������
   *
   */
  procedure import_schema(
    p_master_table  varchar2,
    p_schema        varchar2,
    p_directory     varchar2,
    p_dump_file     varchar2,
    p_log_file      varchar2,
    p_config_fn     varchar2       default null,
    p_only_user     boolean        default false,
    p_metadata_only boolean        default false --test mode
  );
  
  procedure start_job(
    p_handle number
  );
  
end datapump_api;
/
