create or replace package tts_api authid current_user is

  -- Author  : V.ZHURAVOV
  -- Created : 02.06.2018 9:47:06
  -- Purpose : ��������� ��������������� �� � �������������� �����
  
  /**
   * ��������� ���������� �� � ���������������
   *  �������� ����� �� ������������ system!
   *  
   *  1. ��������� ������ ���������
   *  2. ����������� ������� ������ �� XMLTYPE � CLOB 
   *  3. ��������� ������ �������������� �������� � DDL (��� ����������� ����� ��������)
   *  4. �������� ������������ ��������� �������� ������� � �������� (��� ������� date)
   *
   */
  procedure prepare_transport_db(
    x_status    out varchar2,
    x_error_msg out varchar2
  );
  
  /**
   */
  procedure repair_db(
    x_status    out varchar2,
    x_error_msg out varchar2
  );
  
end tts_api;
/
