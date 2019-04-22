SET FEEDBACK OFF
set echo off

def env='&1'
def result='&2'
def action='&3'
def extension='&4'
def add_params='&5'

@&env

conn &_pdh_name/&_pdh_pwd

set serveroutput on
SET FEEDBACK OFF
set echo off
set show off
set verify off

WHENEVER SQLERROR EXIT sql.sqlcode
WHENEVER OSERROR EXIT

spool &result
declare
  l_version    varchar2(100);
  l_commit_sha varchar2(100);

  function get_piece(p_str varchar2, p_pos int) return varchar2 is
    l_result varchar2(32000);
  begin
    return regexp_substr(p_str, '[^[:space:]]+', 1, p_pos);
  end;
begin 
  if '&action' = 'GET_VERSION' then
    dbms_output.put_line(pdh_inst_extensions_pub.request(
      p_extension => '&extension',
      p_property => pdh_inst_extensions_def.C_EP_VERSION
    ));
  elsif '&action' = 'GET_COMMIT_SHA' then
    dbms_output.put_line(pdh_inst_extensions_pub.request(
      p_extension => '&extension',
      p_property => pdh_inst_extensions_def.C_EP_COMMIT_SHA
    ));
  elsif '&action' = 'REGISTER' then
    l_version      := get_piece('&add_params', 1);
    l_commit_sha   := get_piece('&add_params', 2);
    pdh_inst_extensions_pub.set_version(
      p_extension  => '&extension',
      p_version    => l_version,
      p_commit_sha => l_commit_sha
    );
  else
    raise_application_error(-20000, 'Oracle, request.sql: Unknown action ' || '&action');
  end if;
end;
/
spool off

exit
