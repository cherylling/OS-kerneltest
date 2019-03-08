#!/bin/bash

RET=0

if [ "$(uname -r)" \< "4.2" ];then
	addr=`cat /proc/kallsyms | grep "\<do_fork\>" | awk '{print $1}'`
else
	addr=`cat /proc/kallsyms | grep "\<_do_fork\>" | awk '{print $1}'`
fi
dmesg -c > /dev/null

insmod ./jprobe_example.ko
if [ $? -ne 0 ];then
	RET=$(($RET+1))
fi

dmesg | grep "Planted jprobe at $addr"
if [ $? -ne 0 ];then
	echo "Set jprobe failed!"
	RET=$(($RET+2))
fi

ls > /dev/null
dmesg | grep "jprobe: clone_flags"
if [ $? -ne 0 ];then
        echo "Active jprobe failed!"
	RET=$(($RET+4))
fi

rmmod jprobe_example.ko
if [ $? -ne 0 ];then
        RET=$(($RET+8))
fi

echo RET=$RET
exit $RET
