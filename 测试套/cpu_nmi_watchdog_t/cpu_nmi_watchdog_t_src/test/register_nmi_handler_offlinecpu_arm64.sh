#!/bin/bash

cpu_all=`cat /proc/cpuinfo | grep processor | wc -l`

nmi_cleanup()
{
	rmmod arm64_register_nmi_handler.ko
}

main()
{
	cpu_list=$((${cpu_all}-1))
	for i in `seq 0 ${cpu_list}`
	do
		is_cpu_online=`cat /sys/devices/system/cpu/cpu${i}/online`
		if [ ${is_cpu_online} -ne 0 ];then
			echo 0 > /sys/devices/system/cpu/cpu${i}/online
		fi
		
		insmod arm64_register_nmi_handler.ko cpu_num=${i}
		
		if [ $? -eq 0 ];then
			echo 1 > /sys/devices/system/cpu/cpu${i}/online
			echo "Failed:register nmi handler on cpu${i} successfully which unexpected."
			nmi_cleanup
			exit 1
		fi

		echo 1 > /sys/devices/system/cpu/cpu${i}/online

		nmi_cleanup
	done
	
		
}

main
nmi_cleanup

exit 0
