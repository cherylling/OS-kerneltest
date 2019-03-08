#!/bin/bash

nmi_cleanup()
{
	rmmod arm64_register_nmi_handler.ko
}

insmod arm64_register_nmi_handler.ko cpu_num=0

if [ $? -ne 0 ];then
	echo "register nmi handler failed on cpu0."
	nmi_cleanup
	exit 1
fi

sleep 30
dmesg | tail -200 | grep "register my nmi handler on cpu0: dump kernel stack"

if [ $? -ne 0 ];then
	echo "call nmi handler failed on cpu0."
	nmi_cleanup
	exit 1
fi

nmi_cleanup

exit 0
