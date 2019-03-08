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

RET=0

for i in ptrace gdb dump perf ftrace strace breakpoint
do
	funcname=`cat /proc/kallsyms | grep $i | awk '{print $3}'`
	for func_name in $funcname
	do 
	###register kprobes
		echo "p:mykprobe $func_name" > /sys/kernel/debug/tracing/kprobe_events
		cat /sys/kernel/debug/tracing/kprobe_events | grep "p:kprobes/mykprobe $func_name"
		if [ $? -ne 0 ];then
			echo "$func_name register p fail\n" >>kprobe.log
		fi

		echo "r:mykprobe1 $func_name" >> /sys/kernel/debug/tracing/kprobe_events
		cat /sys/kernel/debug/tracing/kprobe_events | grep "r:kprobes/mykprobe1 $func_name"
		if [ $? -ne 0 ];then
        		echo "$func_name register r fail\n" >> kprobe.log
		fi

	###enable
		echo "" > /sys/kernel/debug/tracing/trace
		echo 1 > /sys/kernel/debug/tracing/events/kprobes/mykprobe/enable
		echo 1 > /sys/kernel/debug/tracing/events/kprobes/mykprobe1/enable
		cat /sys/kernel/debug/tracing/trace | grep "mykprobe" && \
		cat /sys/kernel/debug/tracing/trace | grep "mykprobe1"
		if [ $? -ne 0 ];then
        		echo "enable kprobes fail\n"
			RET=$(($RET+1))
		fi

	###disable
		echo 0 > /sys/kernel/debug/tracing/events/kprobes/mykprobe/enable
		echo 0 > /sys/kernel/debug/tracing/events/kprobes/mykprobe1/enable

	###unregister kprobes
		echo >/sys/kernel/debug/tracing/kprobe_events
		ls /sys/kernel/debug/tracing/events/kprobes > /dev/null
		if [ $? -eq 0 ];then
			echo "unregister kprobes fail\n"
			RET=$(($RET+1))
		fi
	done
done

exit $RET

