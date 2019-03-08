#!/bin/bash
echo "this is init.sh!"
i=0
while [ $i -le 500 ]
do
    ssh root@$TARGET_IP "ls /"
    if [ $? -eq 0 ];then
        scp debug_gdb_h_init.sh $TARGET_IP:/tmp/init.sh
        if [ $? -ne 0 ];then
            echo "the board cannot be used"
        else
            echo "the board can be used "
            break
        fi
    fi
    sleep 1
    i=`expr $i + 1`
done

if [ $i -ge 500 ];then
    echo "the board cannot ssh "
fi

ssh -o ConnectTimeout=5 -o ServerAliveInterval=5 -o ServerAliveCountMax=2 root@${TARGET_IP} "rm -rf /tmp/gdb_bin/ ;"
if [ $? -ne 0 ]
then
    echo "create /tmp/gdb_bin on target fail"
fi
scp -r /home/rweb/${VERSION}_${PRODUCT_NAME}_gdb root@${TARGET_IP}:/tmp/gdb_bin
if [ $? -ne 0 ]
then
    echo "scp gdb to target fail"
fi

CDIR=`pwd`
ssh root@$TARGET_IP "mkdir -p /tmp/for_gdb_test"
ssh root@$TARGET_IP "rm -rf /tmp/for_gdb_test/*"
scp -r $CDIR/debug_gdb_h/testcases/bin/* root@$TARGET_IP:/tmp/for_gdb_test/

