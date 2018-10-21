# CASE7
echo "  "
echo "  Starting case 7"
echo "  Calling SQL Plus to do setup for case 7"
sqlplus scott/tiger @ulcase7s
echo "  Calling SQL Loader to load data for case 7"
sqlldr scott/tiger ulcase7 
echo "  Calling SQL Plus to do cleanup for case 7"
sqlplus scott/tiger @ulcase7e
