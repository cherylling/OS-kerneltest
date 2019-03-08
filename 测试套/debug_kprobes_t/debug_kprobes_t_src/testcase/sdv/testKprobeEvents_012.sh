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

###register kprobes in kernel module addr

echo "p:mykprobe cpuinfo_open" > /sys/kernel/debug/tracing/kprobe_events
cat /sys/kernel/debug/tracing/kprobe_events | grep "p:kprobes/mykprobe cpuinfo_open"
if [ $? -ne 0 ];then
	echo "register kprobes fail\n"
	RET=$(($RET+1))
fi

###unregister kprobes
echo > /sys/kernel/debug/tracing/kprobe_events
ls /sys/kernel/debug/tracing/events/kprobes | grep "mykprobe" > /dev/null
if [ $? -eq 0 ];then
	echo "unregister kprobes fail\n"
	RET=$(($RET+2))
fi

echo RET=$RET
exit $RET

