#!/bin/bash

ls /sys/kernel/debug/tracing > /dev/null
if [ $? -ne 0 ];then
	 mount -t debugfs nodev /sys/kernel/debug
fi

ls /sys/kernel/debug/tracing > /dev/null
if [ $? -ne 0 ];then
        echo "not support ftrace\n"
        exit 1
fi

list=`find /sys/kernel/debug/tracing/events/kprobes/ -name "enable"`
for item in $list
do
        echo 0 > $item
done
echo > /sys/kernel/debug/tracing/kprobe_events

RET=0

###register kprobes in user module addr
insmod testKprobes_008-A.ko
if [ $? -ne 0 ];then
        echo "insmod failed!"
        exit 1
fi

echo "r:mykprobe testA" > /sys/kernel/debug/tracing/kprobe_events
cat /sys/kernel/debug/tracing/kprobe_events | grep "r:kprobes/mykprobe testA"
if [ $? -ne 0 ];then
	echo "register kprobes fail\n"
	RET=$(($RET+1))
fi

###unregister kprobes
echo > /sys/kernel/debug/tracing/kprobe_events
ls /sys/kernel/debug/tracing/events/kprobes | grep "mykprobe"
if [ $? -eq 0 ];then
	echo "unregister kprobes fail\n"
	RET=$(($RET+2))
fi

rmmod testKprobes_008-A.ko
if [ $? -ne 0 ];then
        echo "rmmod failed!"
        RET=$(($RET+4))
fi

echo RET=$RET
exit $RET

