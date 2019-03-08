#!/bin/bash

cpu_all=`cat /proc/cpuinfo | grep processor | wc -l`

nmi_cleanup()
{
	rmmod arm64_register_nmi_handler.ko
}

main()
{
	for i in `seq ${cpu_all} 128`
	do
		insmod arm64_register_nmi_handler.ko cpu_num=${i}
		if [ $? -eq 0 ];then
			echo "Failed:register nmi handler on nonexist cpu${i}."
			nmi_cleanup
			exit 1
		fi
	done
}

main
nmi_cleanup

exit 0
