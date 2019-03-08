 #!/bin/bash

 TARGET_PROMPT=192.168.1.234
 ERROR_NO=0
 if [ $# -ne 2 ];then
     echo "param error"
     exit 1
 fi

 TEST_EXPECT_CASE=$1
 TEST_BIN=$2

 ./$TEST_EXPECT_CASE
if [ $? -ne 0 ];then
    echo " $TEST_EXPECT_CASE test error"
    ERROR_NO=`expr $ERROR_NO + 1`
else
    echo " $TEST_EXPECT_CASE test pass"
fi

TO_BE_KILL_PID=`ssh $TARGET_PROMPT ps -ef |grep $TEST_BIN |grep -v "grep $TEST_BIN" |awk '{print $2}'`
for i in $TO_BE_KILL_PID
do
    ssh $TARGET_PROMPT kill -9 $i
    if [ $? -ne 0 ];then
        echo "clean $TEST_BIN error"
        ERROR_NO=`expr $ERROR_NO + 1`
    fi
done
exit $ERROR_NO
