#!/bin/bash

cpu_all=`cat /proc/cpuinfo | grep processor | wc -l`

nmi_cleanup()
{
	rmmod arm64_register_nmi_handler.ko
}

main()
{
	cpu_list=$(($cpu_all-1))
	for i in `seq 0 ${cpu_list}`
	do
		insmod arm64_register_nmi_handler.ko cpu_num=${i}
		if [ $? -ne 0 ];then
			echo "Failed:register nmi handler fialed on cpu${i}"
			nmi_cleanup
			exit 1
		fi

		is_cpu_online=`cat /sys/devices/system/cpu/cpu${i}/online`
		if [ ${is_cpu_online} -ne 0 ];then
			echo 0 > /sys/devices/system/cpu/cpu${i}/online
		fi
		
		dmesg | tail -20 | grep "CPU${i}: shutdown"
		
		if [ $? -ne 0 ];then
			echo "Failed:offline cpu${i} failed."
			nmi_cleanup
			exit 1
		fi

		echo 1 > /sys/devices/system/cpu/cpu${i}/online
		dmesg | tail -20 | grep "CPU${i}: Booted secondary processor"
		if [ $? -ne 0 ];then
                        echo "Failed:online cpu${i} failed."
                        nmi_cleanup
                        exit 1
                fi

		nmi_cleanup
	done
}

main
nmi_cleanup

exit 0
