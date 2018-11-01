/*
Из CDM в GAZFOND_PN:
•  CONTRACT_VERSIONS
•  DEPARTMENTS
•  OFFICE_TEMPLATES

Из GAZFOND_PN в CDM:
•  GRANTS
•  TREENODES (удалю FK на  EMPLOYEES)
•  PAY_ORDER_TYPES
•  DOCUMENT_ERROR_CATEGORIES (удалю FK на  EMPLOYEES)
•  DOCUMENT_ERROR_TYPES (удалю FK на  EMPLOYEES)
•  DOC_ERROR_TYPE_CATEGORIES (удалю FK на  EMPLOYEES)
*/
select *
from   db_move_objects_t o
where  o.object_type = 'TABLE'
and    o.object_name in (
'CONTRACT_VERSIONS',
'DEPARTMENTS',
'OFFICE_TEMPLATES'
)
/
select *
from   db_move_objects_t o
where  o.object_type = 'TABLE'
and    o.object_name in (
'GRANTS',
'TREENODES',
'PAY_ORDER_TYPES',
'DOCUMENT_ERROR_CATEGORIES',
'DOCUMENT_ERROR_TYPES',
'DOC_ERROR_TYPE_CATEGORIES'
)
/
begin
  null;
end;
