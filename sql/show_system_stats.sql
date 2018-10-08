--https://oracle-patches.com/%D0%B1%D0%BB%D0%BE%D0%B3%D0%B8/77-%D0%BD%D0%B0%D1%81%D1%82%D1%80%D0%BE%D0%B9%D0%BA%D0%B0-%D0%BF%D1%80%D0%BE%D0%B8%D0%B7%D0%B2%D0%BE%D0%B4%D0%B8%D1%82%D0%B5%D0%BB%D1%8C%D0%BD%D0%BE%D1%81%D1%82%D0%B8/3107-%D0%BE%D0%BF%D1%82%D0%B8%D0%BC%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F-%D0%B7%D0%B0%D0%BF%D1%80%D0%BE%D1%81%D0%BE%D0%B2-%D0%B8-oracle-cbo
SELECT * FROM sys.aux_stats$;
/
/*
EXECUTE dbms_stats.gather_system_stats('stop');
*/

exec sys.dbms_stats.gather_system_stats('START');

alter session disable parallel query;

select /*+ FULL(a) */ count(*) from gazfond_pn.people a;

exec sys.dbms_stats.gather_system_stats('STOP');
/
--start at 8:42
begin
  sys.dbms_stats.gather_system_stats('INTERVAL', 240);
end;
/*
before:
SYSSTATS_INFO STATUS    COMPLETED
SYSSTATS_INFO DSTART    09-15-2018 09:00
SYSSTATS_INFO DSTOP   09-15-2018 09:00
SYSSTATS_INFO FLAGS 1 
SYSSTATS_MAIN CPUSPEEDNW  1518  
SYSSTATS_MAIN IOSEEKTIM 4 
SYSSTATS_MAIN IOTFRSPEED  67104 
SYSSTATS_MAIN SREADTIM  1,503 
SYSSTATS_MAIN MREADTIM    
SYSSTATS_MAIN CPUSPEED  1518  
SYSSTATS_MAIN MBRC    
SYSSTATS_MAIN MAXTHR    
SYSSTATS_MAIN SLAVETHR    

*/
