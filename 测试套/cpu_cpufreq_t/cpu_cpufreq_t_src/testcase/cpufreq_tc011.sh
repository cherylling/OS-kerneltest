#!/bin/bash

source ./cpufreq_conf.sh

cpu_num=`./cpu_num`
ret=0

i=0
while [ $i -lt $cpu_num ]
do
	saved_governors=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor`
	saved_freq=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq`

	available_governors=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_available_governors`
	available_frequencies=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_available_frequencies`
	list_freq=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_available_frequencies`
	mid_freq=`middle $list_freq`

	saved_max=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq`
	saved_min=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq`

	echo $mid_freq > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq
	echo $mid_freq > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq

	echo "ondemand" > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
#	./cpu_load $i 50 &
#	pid=$!
	sleep 5
	cur_freq=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq`

	if [ $cur_freq != $mid_freq ]
	then
		echo "cur_freq=$cur_freq"
		echo "core $i : scaling_min_freq and scaling_max_freq test failed !"
		ret=$(($ret+1))
	else
		echo "core $i : scaling_min_freq and scaling_max_freq test passed !"
	fi

	echo $saved_max > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq
	echo $saved_min > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq
####restore governors
	echo $saved_governors > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
#	kill -9 $pid
	i=$(($i+1))
done

exit $ret

