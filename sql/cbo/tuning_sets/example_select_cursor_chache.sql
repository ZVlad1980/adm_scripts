-- Get sql ids and sql text for statements with 500 buffer gets.
SELECT sql_id, sql_text 
FROM table(DBMS_SQLTUNE.SELECT_CURSOR_CACHE('buffer_gets > 500')) 
ORDER BY sql_id;
 
-- Get all the information we have about a particular statement.
SELECT * 
FROM table(DBMS_SQLTUNE.SELECT_CURSOR_CACHE('sql_id = ''4rm4183czbs7j'''));
 
-- Notice that some statements can have multiple plans.  The output of the
-- SELECT_XXX table functions is unique by (sql_id, plan_hash_value).  This is
-- because a data source can store multiple plans per sql statement.
SELECT sql_id, plan_hash_value
FROM table(dbms_sqltune.select_cursor_cache('sql_id = ''ay1m3ssvtrh24'''))
ORDER BY sql_id, plan_hash_value;
 
-- PL/SQL examples: load_sqlset is called after opening a cursor, along the
-- lines given below
 
-- Select all statements in the shared SQL area.
DECLARE
  cur sys_refcursor;
BEGIN
  OPEN cur FOR
    SELECT value(P) 
    FROM table(DBMS_SQLTUNE.SELECT_CURSOR_CACHE) P;
 
  -- Process each statement (or pass cursor to load_sqlset).
 
  CLOSE cur;
END;/
 
 
-- Look for statements not parsed by SYS.
DECLARE
  cur sys_refcursor;
BEGIN
  OPEN cur for
    SELECT VALUE(P) 
    FROM table(
     DBMS_SQLTUNE.SELECT_CURSOR_CACHE('parsing_schema_name <> ''SYS''')) P;
 
  -- Process each statement (or pass cursor to load_sqlset).
 
  CLOSE cur;
end;/
 
 
-- All statements from a particular module/action.
DECLARE
  cur sys_refcursor;
BEGIN
  OPEN cur FOR
    SELECT VALUE(P) 
    FROM table(
      DBMS_SQLTUNE.SELECT_CURSOR_CACHE(
         'module = ''MY_APPLICATION'' and action = ''MY_ACTION''')) P;
 
  -- Process each statement (or pass cursor to load_sqlset)
 
  CLOSE cur;
END;/
 
 
-- all statements that ran for at least five seconds
DECLARE
  cur sys_refcursor;
BEGIN
  OPEN cur FOR
    SELECT VALUE(P) 
    FROM table(DBMS_SQLTUNE.SELECT_CURSOR_CACHE('elapsed_time > 5000000')) P;
 
  -- Process each statement (or pass cursor to load_sqlset)
 
  CLOSE cur;
end;/
 
 
-- select all statements that pass a simple buffer_gets threshold and 
-- are coming from an APPS user
DECLARE
  cur sys_refcursor;
BEGIN
  OPEN cur FOR
    SELECT VALUE(P) 
    FROM table(
      DBMS_SQLTUNE.SELECT_CURSOR_CACHE(
        'buffer_gets > 100 and parsing_schema_name = ''APPS'''))P;
 
  -- Process each statement (or pass cursor to load_sqlset)
 
  CLOSE cur;
end;/
 
 
-- select all statements exceeding 5 seconds in elapsed time, but also
-- select the plans (by default we only select execution stats and binds
-- for performance reasons - in this case the SQL_PLAN attribute of sqlset_row
-- is NULL) 
DECLARE
  cur sys_refcursor;
BEGIN
  OPEN cur FOR
    SELECT VALUE(P) 
    FROM table(dbms_sqltune.select_cursor_cache(
      'elapsed_time > 5000000', NULL, NULL, NULL, NULL, 1, NULL,
      'EXECUTION_STATISTICS, SQL_BINDS, SQL_PLAN')) P;
 
  -- Process each statement (or pass cursor to load_sqlset)
 
  CLOSE cur;
END;
/
 
 
-- Select the top 100 statements in the shared SQL area ordering by elapsed_time.
DECLARE
  cur sys_refcursor;
BEGIN
  OPEN cur FOR
    SELECT VALUE(P) 
    FROM table(DBMS_SQLTUNE.SELECT_CURSOR_CACHE(NULL,
                                                NULL,
                                                'ELAPSED_TIME', NULL, NULL,
                                                1,
                                                100)) P;
 
  -- Process each statement (or pass cursor to load_sqlset)
 
  CLOSE cur;
end;/
 
 
-- Select the set of statements which cumulatively account for 90% of the 
-- buffer gets in the shared SQL area.  This means that the buffer gets of all
-- of these statements added up is approximately 90% of the sum of all 
-- statements currently in the cache.
DECLARE
  cur sys_refcursor;
BEGIN
  OPEN cur FOR
    SELECT VALUE(P) 
    FROM table(DBMS_SQLTUNE.SELECT_CURSOR_CACHE(NULL,
                                                NULL,
                                                'BUFFER_GETS', NULL, NULL,
                                                .9)) P;
 
  -- Process each statement (or pass cursor to load_sqlset).
 
  CLOSE cur;
END;
/
