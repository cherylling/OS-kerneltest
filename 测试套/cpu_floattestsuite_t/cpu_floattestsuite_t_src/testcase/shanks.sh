 #!/bin/bash



 WORK_DIR=`pwd`

 cd ../conf
 FILES=`ls *.fptest`

 cd $WORK_DIR

 for f in $FILES
 do
    ./floattest $f 
 done

