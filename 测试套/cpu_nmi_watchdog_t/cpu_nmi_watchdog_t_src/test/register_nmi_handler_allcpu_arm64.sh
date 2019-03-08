#!/bin/bash

cpu_all=`cat /proc/cpuinfo | grep processor | wc -l`

nmi_cleanup()
{
	rmmod arm64_enable_all_nmi.ko
}

main()
{
	insmod arm64_enable_all_nmi.ko cpu_total=${cpu_all}
	if [ $? -ne 0 ];then
        	echo "register nmi handler failed on all cpus."
	        nmi_cleanup
        	exit 1
	fi

	sleep 60

	dmesg | tail -500 | grep "register my nmi handler on all cpus: dump kernel stack"

	if [ $? -ne 0 ];then
        	echo "call nmi handler failed."
	        nmi_cleanup
        	exit 1
	fi
}

main
nmi_cleanup

exit 0
