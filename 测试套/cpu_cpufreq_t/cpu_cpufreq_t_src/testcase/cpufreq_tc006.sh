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

echo $mid_freq	
	echo "userspace" > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
	echo $mid_freq > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_setspeed

	./cpu_load $i 80 &
	pid=$!
	sleep 1
	cur_freq=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq`
	if [ $cur_freq != $mid_freq ]
	then
		echo "core $i : case 1 : performance governor test failed !"
		ret=$(($ret+1))
	else
		echo "core $i : case 1 : performance governor test passed !"
	fi
	kill -9 $pid

	./cpu_load $i 5 &
	pid=$!
	sleep 5
	cur_freq=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq`
	if [ $cur_freq != $mid_freq ]
	then
		echo "core $i : case 2 : userspace governor test failed !"
		ret=$(($ret+1))
	else
		echo "core $i : case 2 : userspace governor test passed !"
	fi
	kill -9 $pid

####restore governors
	echo $saved_governors > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
	i=$(($i+1))
done

exit $ret

