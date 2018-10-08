#! /bin/bash
DIR=`/bin/dirname $0`
. $DIR/clone_pdb.conf
. $DIR/create_db_files.cmd
/bin/mv $DIR/clone_pdb.conf $DIR/clone_pdb.last
/bin/mv $DIR/create_db_files.cmd $DIR/create_db_files.last
/bin/rm -f $DIR/CLONE*
/bin/rm -f $DIR/FILES*
echo "COMPLETE"
