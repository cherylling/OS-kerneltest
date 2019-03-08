#!/bin/bash

source ./cpufreq_conf.sh
cpu_num=`./cpu_num`

ret=0
i=0

scaling_available_governors="conservative ondemand userspace powersave performance"
for (( i=0; i<$cpu_num; i++ ))
do
	available_governor="`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_available_governors`"
	
	for governor in $scaling_available_governors
	do
		echo $available_governor |grep "$governor"
		if [ $? -ne 0 ]; then
			echo "$governor not support in cpu$i."
			ret=$(($ret + 1))
		fi
	done
done

exit $ret
