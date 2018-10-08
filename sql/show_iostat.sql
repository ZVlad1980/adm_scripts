with iostat_file as 
  (select filetype_name,sum(large_read_reqs) large_read_reqs,
          sum(large_read_servicetime) large_read_servicetime,
          sum(large_write_reqs) large_write_reqs,
          sum(large_write_servicetime) large_write_servicetime,
          sum(small_read_reqs) small_read_reqs,
          sum(small_read_servicetime) small_read_servicetime,
          sum(small_sync_read_latency) small_sync_read_latency,
          sum(small_sync_read_reqs) small_sync_read_reqs,
          sum(small_write_reqs) small_write_reqs,
          sum(small_write_servicetime) small_write_servicetime
     from sys.v_$iostat_file
    group by filetype_name)
select filetype_name, small_read_reqs + large_read_reqs reads,
       large_write_reqs + small_write_reqs writes,
       round((small_read_servicetime + large_read_servicetime)/1000) 
          read_time_sec,
       round((small_write_servicetime + large_write_servicetime)/1000) 
          write_time_sec,
       case when small_sync_read_reqs > 0 then 
          round(small_sync_read_latency / small_sync_read_reqs, 2) 
       end avg_sync_read_ms,
       round((  small_read_servicetime+large_read_servicetime
              + small_write_servicetime + large_write_servicetime)
             / 1000, 2)  total_io_seconds
  from iostat_file
 order by 7 desc;
