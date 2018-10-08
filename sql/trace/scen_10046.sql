
Event Level Settings
Level	Setting
1	Default SQL Trace
4	Include bind variable information
8	Include wait event information
12	Include bind variable and wait event information
By default, each SQL Trace is set to level 1. To enable extra information to be reported, the 10046 Event is set to the desired reporting level using the ALTER SESSION command.

ALTER SESSION SET EVENTS '10046 trace name context forever, level 1';
ALTER SESSION SET EVENTS '10046 trace name context forever, level 4';
ALTER SESSION SET EVENTS '10046 trace name context forever, level 8';
ALTER SESSION SET EVENTS '10046 trace name context forever, level 12';

ALTER SESSION SET EVENTS '10046 trace name context off';