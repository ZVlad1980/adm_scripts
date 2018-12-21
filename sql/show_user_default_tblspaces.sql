select username,
       default_tablespace,
       temporary_tablespace
from   dba_users
where  username = 'DEV_PDH';
