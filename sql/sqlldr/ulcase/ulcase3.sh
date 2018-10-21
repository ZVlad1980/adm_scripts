# CASE3
echo "  "
echo "  Starting case 3"
echo "  Calling SQL Plus to do setup for case 3"
sqlplus scott @ulcase3
echo "  Calling SQL Loader to load data for case 3"
sqlldr scott ulcase3
