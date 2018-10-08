/*https://oracleracdba1.wordpress.com/2014/08/06/how-to-set-idle-time-in-oracle-database/
alter system set resource_limit= true scope=both;
ALTER PROFILE DEFAULT LIMIT IDLE_TIME 60;
ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;
*/

select *
from   user_resource_limits a
where  a.resource_name in ('IDLE_TIME', 'CONNECT_TIME');
/
select *
from   dba_profiles
where  profile = 'DEFAULT'
and    resource_name in ('IDLE_TIME', 'CONNECT_TIME');
