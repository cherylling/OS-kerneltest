#!/bin/bash

source ./cpufreq_conf.sh

cpu_num=`./cpu_num`
ret=0

i=1
while [ $i -lt $cpu_num ]
do
	saved_governors=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor`
	saved_freq=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq`

	available_governors=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_available_governors`
	available_frequencies=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_available_frequencies`
	min_freq=`min $available_frequencies`

	echo 0 > /sys/devices/system/cpu/cpu$i/online
	sleep 1
	echo 1 > /sys/devices/system/cpu/cpu$i/online
	echo "ondemand" > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
	sleep 2 
	cur_freq=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq`
#	echo "cur_freq=$cur_freq"
	if [ $cur_freq != $min_freq ]
	then
		echo "cur_freq=$cur_freq"
		echo "core $i : ondemand governor test failed !"
		ret=$(($ret+1))
	else
		echo "core $i : ondemand governor test passed !"
	fi
#	kill -9 $pid

####restore governors
	echo $saved_governors > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
	i=$(($i+1))
done

exit $ret

