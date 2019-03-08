#!/bin/bash

addr=`cat /proc/kallsyms | grep "\<do_fork\>" | awk '{print $1}'`
cpu_all=`cat /proc/cpuinfo | grep processor | wc -l`

nmi_cleanup()
{
	rmmod arm64_enable_all_nmi.ko
	rmmod jprobe_example.ko
	rmmod kprobe_example.ko
	rmmod kretprobe_example.ko
}

main()
{
	insmod arm64_enable_all_nmi.ko cpu_total=${cpu_all}
	if [ $? -ne 0 ];then
        	echo "register nmi handler for oneshot failed on all cpus."
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

	#test nmi&jprobe
	insmod jprobe_example.ko
	if [ $? -ne 0 ];then
		echo "test jprobe&nmi failed."
		nmi_cleanup
		exit 1
	fi

	dmesg | grep "Planted jprobe at $addr"
	if [ $? -ne 0 ];then
		echo "Set jprobe failed!"
		nmi_cleanup
		exit 1
	fi

	ls > /dev/null
	dmesg | grep "jprobe: clone_flags"
	if [ $? -ne 0 ];then
		echo "Active jprobe failed!"
		nmi_cleanup
		exit 1
	fi

	#test nmi&kprobe
	insmod kprobe_example.ko
	if [ $? -ne 0 ];then
                echo "test kprobe&nmi failed."
                nmi_cleanup
                exit 1
        fi

	dmesg | grep "Planted kprobe at $addr"
        if [ $? -ne 0 ];then
                echo "Set kprobe failed!"
                nmi_cleanup
                exit 1
        fi

        ls > /dev/null
        dmesg | grep "post_handler"
        if [ $? -ne 0 ];then
                echo "Active kprobe failed!"
                nmi_cleanup
                exit 1
        fi

	#test nmi&kretprobe
	insmod kretprobe_example.ko
	if [ $? -ne 0 ];then
                echo "test kretprobe&nmi failed."
                nmi_cleanup
                exit 1
        fi

	dmesg | grep "Planted return probe at do_fork: $addr"
        if [ $? -ne 0 ];then
                echo "Set kretprobe failed!"
                nmi_cleanup
                exit 1
        fi

        ls > /dev/null
        dmesg | grep "do_fork returned"
        if [ $? -ne 0 ];then
                echo "Active kretprobe failed!"
                nmi_cleanup
                exit 1
        fi
}

main
nmi_cleanup

exit 0
