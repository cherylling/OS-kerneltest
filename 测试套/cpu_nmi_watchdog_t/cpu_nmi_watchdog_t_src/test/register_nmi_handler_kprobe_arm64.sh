#!/bin/bash

nmi_cleanup()
{
	rmmod arm64_enable_all_nmi.ko
	rmmod kprobe_my_nmi.ko
	rmmod kprobe_nmi.ko
}

register_nmi_handler_addr=`cat /proc/kallsyms | grep register_nmi_handler | awk '{print $1}' | head -1`

insmod kprobe_nmi.ko
if [ $? -ne 0 ];then
	echo "insmod kprobe_nmi error."
	nmi_cleanup
	exit 1
fi

dmesg | tail -200 | grep "Planted kprobe at ${register_nmi_handler_addr}"
if [ $? -ne 0 ];then
        echo "register kprobe for register_nmi_handler failed."
        nmi_cleanup
        exit 1
fi

insmod arm64_enable_all_nmi.ko
if [ $? -ne 0 ];then
	echo "register nmi handler failed."
	nmi_cleanup
	exit 1
fi

sleep 30
dmesg | tail -200 | grep "register my nmi handler on all cpus: dump kernel stack"
if [ $? -ne 0 ];then
	echo "call nmi handler failed."
	nmi_cleanup
	exit 1
fi

register_my_nmi_handler_addr=`cat /proc/kallsyms | grep my_nmi_handler | awk '{print $1}'`

insmod kprobe_my_nmi.ko
if [ $? -ne 0 ];then
        echo "insmod kprobe_my_nmi error."
        nmi_cleanup
        exit 1
fi

dmesg | tail -200 | grep "Planted kprobe at ${register_my_nmi_handler_addr}"
if [ $? -ne 0 ];then
        echo "register kprobe for register_nmi_handler failed."
        nmi_cleanup
        exit 1
fi

sleep 30
nmi_cleanup
exit 0
