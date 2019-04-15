select /*+
         cursor_sharing_exact
         dynamic_sampling(0)
         no_monitoring
         no_expand
         index(t1, T1_I1_BAD)
       */
       sys_op_countchg(substrb(t1.rowid, 1, 15), &m_history) as clf
from   tst.t1 t1
where  movement_date is not null
or     product_id is not null
