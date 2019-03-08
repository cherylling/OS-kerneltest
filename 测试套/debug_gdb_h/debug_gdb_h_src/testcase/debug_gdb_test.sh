 #!/bin/bash

 TARGET_IP=$TARGET_IP 
 ERROR_NO=0
 if [ $# -ne 3 ];then
     echo "param error"
     exit 1
 fi

 TEST_TYPES=$1
 TEST_EXPECT_CASE=$2
 TEST_BIN=$3

# default vail (important)
if [ -z "$CROSS_COMPILE_SDK" ]; then
	export CROSS_COMPILE_SDK=gcc
fi
if [ -z "$ARCH" ]; then
        export ARCH=x86_64
fi
if [ -z "$GDB_TOOL_DIR" ]; then
        export GDB_TOOL_DIR="/usr/bin/"
fi
if [ -z "$TARGET_PROMPT" ]; then
        export TARGET_PROMPT="#"
fi
if [ -z "$PRODUCT_NAME" ]; then
	export PRODUCT_NAME=$TARGET_PROMPT
fi


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
        echo "WARNING clean $TEST_BIN error"
    fi
done
exit $ERROR_NO
