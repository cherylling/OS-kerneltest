#!/bin/sh
cd `dirname $0`
rm -f ./FS_TESTDIR.conf

USE_EXT4_FIRST=1


hostname | grep "GUESTOS"
if [ $? -eq 0 ];then
    echo '/tmp' > ./FS_TESTDIR.conf
    exit 0
fi

