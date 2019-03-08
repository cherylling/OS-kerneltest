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

###register kprobes
echo "p:mykprobe cpuinfo_open" > /sys/kernel/debug/tracing/kprobe_events
cat /sys/kernel/debug/tracing/kprobe_events | grep "p:kprobes/mykprobe cpuinfo_open"
if [ $? -ne 0 ];then
	echo "register kprobes fail\n"
	RET=$(($RET+1))
fi
echo 'r:myretprobe cpuinfo_open $retval' >> /sys/kernel/debug/tracing/kprobe_events
cat /sys/kernel/debug/tracing/kprobe_events | grep "r:kprobes/myretprobe cpuinfo_open"
if [ $? -ne 0 ];then
        echo "register kprobes fail\n"
        RET=$(($RET+1))
fi

for num in `seq 0 1 100`
do
	###enable
	echo "" > /sys/kernel/debug/tracing/trace
	echo 1 > /sys/kernel/debug/tracing/events/kprobes/mykprobe/enable
	echo 1 > /sys/kernel/debug/tracing/events/kprobes/myretprobe/enable
	cat /proc/cpuinfo > /dev/null
	cat /sys/kernel/debug/tracing/trace | grep "mykprobe" && \
	cat /sys/kernel/debug/tracing/trace | grep "myretprobe" 
	if [ $? -ne 0 ];then
        	echo "enable kprobes fail\n"
                RET=$(($RET+1))
	fi
	###disable
	echo 0 > /sys/kernel/debug/tracing/events/kprobes/mykprobe/enable
	echo 0 > /sys/kernel/debug/tracing/events/kprobes/myretprobe/enable
done
###unregister kprobes
echo > /sys/kernel/debug/tracing/kprobe_events
ls /sys/kernel/debug/tracing/events/kprobes | grep "mykprobe" || \
ls /sys/kernel/debug/tracing/events/kprobes | grep "myretprobe"
if [ $? -eq 0 ];then
	echo "unregister kprobes fail\n"
	RET=$(($RET+1))
fi

exit $RET

