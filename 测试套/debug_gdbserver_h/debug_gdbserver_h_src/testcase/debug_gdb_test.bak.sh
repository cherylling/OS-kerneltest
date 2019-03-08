 #!/bin/bash

 TARGET_IP=x.x.x.x
 ERROR_NO=0
 if [ $# -ne 3 ];then
     echo "param error"
     exit 1
 fi

 TEST_TYPES=$1
 TEST_EXPECT_CASE=$2
 TEST_BIN=$3

 cd $TEST_TYPES
 ./$TEST_EXPECT_CASE
if [ $? -ne 0 ];then
    echo " $TEST_EXPECT_CASE test error"
    ERROR_NO=`expr $ERROR_NO + 1`
else
    echo " $TEST_EXPECT_CASE test pass"
fi

sleep 3
TO_BE_KILL_PID=`ssh $TARGET_IP ps -ef |grep $TEST_BIN |grep -v "grep $TEST_BIN" |awk '{print $2}'`
for i in $TO_BE_KILL_PID
do
    ssh $TARGET_IP kill -9 $i
    if [ $? -ne 0 ];then
        echo "clean $TEST_BIN error"
        ERROR_NO=`expr $ERROR_NO + 1`
    fi
done
exit $ERROR_NO
