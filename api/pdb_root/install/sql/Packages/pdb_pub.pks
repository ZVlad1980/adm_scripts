create or replace package pdb_pub is

  -- Author  : V.ZHURAVOV
  -- Created : 29.04.2018 14:43:23
  -- Purpose : �������� ��� PDB_API
  
  GC_RFR_NO           constant varchar2(20) := 'NO';             --�� ���������
  GC_RFR_DAILY        constant varchar2(20) := 'DAILY';          --���������� ����������
  GC_RFR_PARENT       constant varchar2(20) := 'UPDATE_PARENT';  --���������� ����� ���������� ������������� ���������� (�.�. ���� ����� ����������, ����� ���������� ��������)
  
  GC_FRZ_YES          constant varchar2(20) := 'YES';
  GC_FRZ_NO           constant varchar2(20) := 'NO';
  
  /**
   * ��������� clone - �������� ����� PDB_NODE
   * 
   * p_creator     - ��� ���������
   * p_pdb_name    - ��� ������������ �����
   * p_pdb_parent  - ��� PDB-���������
   *
   *  ���� p_refreshable ��� p_freeze ������� �� ��������� �������� - ������� �� ����� ���������� � �������, ��
   *    � ������� PDB_CLONES_T ����� ������ ������ � ����� �����, �������, � ���� �������, 
   *    ����� ������ ��� ��������� ������������ ��
   */
  procedure clone(
    p_creator      varchar2,
    p_pdb_name     varchar2,
    p_pdb_parent   varchar2
  );
  
  /**
   * ��������� clone - �������� ����� PDB_NODE
   * 
   * p_creator     - ��� ���������
   * p_pdb_name    - ��� ������������ �����
   * p_pdb_parent  - ��� PDB-���������
   * p_refreshable - ����� ���������� 
   * p_freeze      - ��������� �����
   *
   *  ���� p_refreshable ��� p_freeze ������� �� ��������� �������� - ������� �� ����� ���������� � �������, ��
   *    � ������� PDB_CLONES_T ����� ������ ������ � ����� �����, �������, � ���� �������, 
   *    ����� ������ ��� ��������� ������������ ��
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
   * ��������� set_refreshable - ������������� ����� ���������� �����
   * 
   * p_pdb_name - ��� PDB
   * p_refresh  - ����� ����������, ��. ���� ��������� GC_PFR
   *
   */
  procedure set_refreshable(
    p_pdb_name varchar2,
    p_refresh  varchar2
  );
  
  /**
   * ��������� request_drop ������� PDB ��� ��������, �.�. ������ ��������� � ������� ���� �� �����������
   *   ���� �������� ����� ��������� ��� ������������ ��
   */
  procedure request_drop(
    p_pdb_name varchar2
  );
  
end pdb_pub;
/
