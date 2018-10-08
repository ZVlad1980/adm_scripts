DECLARE
   --threads pls_integer := &&1;
BEGIN
   utl_recomp.recomp_parallel(1, 'SYS');
END;
