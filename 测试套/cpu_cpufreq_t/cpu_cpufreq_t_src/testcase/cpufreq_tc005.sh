#!/bin/bash

source ./cpufreq_conf.sh

cpu_num=`./cpu_num`
ret=0

i=0
while [ $i -lt $cpu_num ]
do
	saved_governors=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor`
	available_governors=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_available_governors`
	available_frequencies=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_available_frequencies`
	list_freq=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_available_frequencies`
	min_freq=`min $list_freq`
	echo "powersave" > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor

	./cpu_load $i 80 &
	pid=$!
	sleep 1
	
	cur_freq=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq`
	echo $cur_freq
	if [ $cur_freq != $min_freq ]
	then
		echo "core $i : powersave governor test failed !"
		ret=$(($ret+1))
	else
		echo "core $i : powersave governor test passed !"
	fi
####restore governors
	echo $saved_governors > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
	kill -9 $pid
	i=$(($i+1))
done

exit $ret

