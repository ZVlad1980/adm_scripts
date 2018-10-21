# CASE1
echo "  "
echo "  Starting case 1"
echo "  Calling SQL Plus to do setup for case 1"
sqlplus scott/tiger @ulcase1
echo "  Calling SQL Loader to load data for case 1"
sqlldr scott/tiger ulcase1.ctl
