# CASE5
echo "  "
echo "  Starting case 5"
echo "  Calling SQL Plus to do setup for case 5"
sqlplus scott/tiger @ulcase5
echo "  Calling SQL Loader to load data for case 5"
sqlldr scott/tiger ulcase5
