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
echo "p:mykprobe do_sys_open" > /sys/kernel/debug/tracing/kprobe_events
cat /sys/kernel/debug/tracing/kprobe_events | grep "p:kprobes/mykprobe do_sys_open"
if [ $? -ne 0 ];then
	echo "register kprobes fail\n"
	RET=$(($RET+1))
fi
echo 'r:myretprobe do_sys_open $retval' >> /sys/kernel/debug/tracing/kprobe_events
cat /sys/kernel/debug/tracing/kprobe_events | grep "r:kprobes/myretprobe do_sys_open"
if [ $? -ne 0 ];then
        echo "register kprobes fail\n"
        RET=$(($RET+2))
fi

###enable
echo "" > /sys/kernel/debug/tracing/trace
echo 1 > /sys/kernel/debug/tracing/events/kprobes/mykprobe/enable
echo 1 > /sys/kernel/debug/tracing/events/kprobes/myretprobe/enable
ls > /dev/null
cat /sys/kernel/debug/tracing/trace | grep "mykprobe" && \
cat /sys/kernel/debug/tracing/trace | grep "myretprobe" 
if [ $? -ne 0 ];then
        echo "enable kprobes fail\n"
        RET=$(($RET+4))
fi

###disable
echo 0 > /sys/kernel/debug/tracing/events/kprobes/mykprobe/enable
echo 0 > /sys/kernel/debug/tracing/events/kprobes/myretprobe/enable
###unregister kprobes
echo -:mykprobe >>/sys/kernel/debug/tracing/kprobe_events
ls /sys/kernel/debug/tracing/events/kprobes | grep "mykprobe" > /dev/null
if [ $? -eq 0 ];then
	echo "unregister kprobes fail\n"
	RET=$(($RET+8))
fi

echo -:myretprobe >>/sys/kernel/debug/tracing/kprobe_events
ls /sys/kernel/debug/tracing/events/kprobes | grep "myretprobe" > /dev/null
if [ $? -eq 0 ];then
        echo "unregister kprobes fail\n"
        RET=$(($RET+16))
fi
echo RET=$RET
exit $RET

