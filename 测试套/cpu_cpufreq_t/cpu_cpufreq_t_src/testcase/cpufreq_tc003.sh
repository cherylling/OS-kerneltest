#!/bin/bash

source ./cpufreq_conf.sh

cpu_num=`./cpu_num`

i=0
while [ $i -lt $cpu_num ]
do
	saved_governors=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor`
	available_governors=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_available_governors`
####available governors	
	for governors in $available_governors
	do
		echo $governors > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
		if [ $? -ne 0 ]
		then
			echo "write \"$governors\" to \"/sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor\" failed unexpected !"
			ret=$(($ret+1))
		fi
	done
####error governors
	echo "xxxxxxxxxxxxx" > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
	if [ $? -eq 0 ]
	then
		echo "write \"xxxxxxxxxxxxx\" to \"/sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor\" successed unexpected !"
		ret=$(($ret+1))
	fi
####restore governors
	echo $saved_governors > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
	i=$(($i+1))
done

exit $ret

