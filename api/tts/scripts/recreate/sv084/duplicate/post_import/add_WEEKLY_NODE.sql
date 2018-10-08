begin
  -- Test statements here
  pdb_api.add_database(
    p_pdb_name   => 'WEEKLY_NODE',
    p_clone_name => 'WEEKLY_CLONE',
    p_acfs_path  => '/u01/app/oracle/oradata/weekly'
  );
end;
/
exit;