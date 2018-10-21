# CASE4
echo "  "
echo "  Starting case 4"
echo "  Calling SQL Plus to do setup for case 4"
sqlplus scott/tiger @ulcase4
echo "  Calling SQL Loader to load data for case 4"
sqlldr scott/tiger ulcase4
