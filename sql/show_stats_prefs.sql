select dbms_stats.get_prefs('STALE_PERCENT', user, 'ASSIGNMENTS') stale_percent
from dual
