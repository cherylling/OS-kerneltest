#!/bin/bash

ls /sys/kernel/debug/tracing > /dev/null
if [ $? -ne 0 ];then
	 mount -t debugfs nodev /sys/kernel/debug
fi

ls /sys/kernel/debug/tracing > /dev/null
if [ $? -ne 0 ];then
        echo "not support ftrace"
        exit 1
fi

list=`find /sys/kernel/debug/tracing/events/kprobes/ -name "enable"`
for item in $list
do
        echo 0 > $item
done
echo > /sys/kernel/debug/tracing/kprobe_events

RET=0

###stacktrace
echo stacktrace > /sys/kernel/debug/tracing/trace_options
echo "p cpuinfo_open" > /sys/kernel/debug/tracing/kprobe_events
cat /sys/kernel/debug/tracing/kprobe_events | grep "cpuinfo_open"
if [ $? -ne 0 ];then
	echo "register kprobes fail"
	RET=$(($RET+1))
fi

echo > /sys/kernel/debug/tracing/trace
echo 1 > /sys/kernel/debug/tracing/events/kprobes/enable
cat /proc/cpuinfo > /dev/null
cat /sys/kernel/debug/tracing/trace | grep "stack trace"
if [ $? -ne 0 ];then
        echo "nostacktrace fail"
        RET=$(($RET+2))
fi


###nostacktrace
echo > /sys/kernel/debug/tracing/trace
echo nostacktrace > /sys/kernel/debug/tracing/trace_options
cat /proc/cpuinfo > /dev/null
cat /sys/kernel/debug/tracing/trace | grep "stack trace"
if [ $? -eq 0 ];then
        echo "nostacktrace fail"
        RET=$(($RET+4))
fi


###disable
echo 0 > /sys/kernel/debug/tracing/events/kprobes/enable
###unregister kprobes
echo > /sys/kernel/debug/tracing/kprobe_events
cat /sys/kernel/debug/tracing/kprobe_events | grep "p cpuinfo_open" > /dev/null
if [ $? -eq 0 ];then
        echo "unregister kprobes fail"
        RET=$(($RET+8))
fi

echo RET=$RET
exit $RET

