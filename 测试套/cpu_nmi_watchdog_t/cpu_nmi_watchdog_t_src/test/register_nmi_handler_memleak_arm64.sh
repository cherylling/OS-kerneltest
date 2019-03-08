#!/bin/bash

loop=1000
cpu_all=`cat /proc/cpuinfo | grep processor | wc -l`

nmi_cleanup()
{
	rmmod arm64_enable_all_nmi.ko
}

register_nmi_handler()
{
	insmod arm64_enable_all_nmi.ko cpu_total=${cpu_all} time_out=5
	if [ $? -ne 0 ];then
        	echo "register nmi handler failed on all cpus."
	        nmi_cleanup
        	exit 1
	fi

	sleep 10

	rmmod arm64_enable_all_nmi.ko

	if [ $? -ne 0 ];then
        	echo "rmmod arm64_enable_all_nmi failed."
	        nmi_cleanup
        	exit 1
	fi
}

echo 3 > /proc/sys/vm/drop_caches
free_memory_begin=`cat /proc/meminfo | grep MemFree | awk '{print $2}'`

for testloop in `seq 1 ${loop}`
do
	register_nmi_handler
done

echo 3 > /proc/sys/vm/drop_caches
free_memory_end=`cat /proc/meminfo | grep MemFree | awk '{print $2}'`

memory_rise=`expr ${free_memory_end} - ${free_memory_begin}`
if [ ${memory_rise} -gt 20480 ];then
	echo "Memoryleak check failed. Memory start:${free_memory_begin}KB,Memory end:${free_memory_end}KB"
	nmi_cleanup
	exit 1
fi

nmi_cleanup
exit 0
