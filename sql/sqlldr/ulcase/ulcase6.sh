# CASE6
echo "  "
echo "  Starting case 6"
echo "  Calling SQL Plus to do setup for case 6"
sqlplus scott/tiger @ulcase6
echo "  Calling SQL Loader to load data for case 6"
sqlldr scott/tiger ulcase6 direct=true
