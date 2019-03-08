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
	max_freq=`max $list_freq`

	echo "conservative" > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor

	./cpu_load $i 90 &
	pid=$!
	sleep 5 
	cur_freq1=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq`
	usleep 10000
	cur_freq2=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq`
	usleep 10000
	cur_freq3=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq`
	cur_freq=`max $cur_freq1 $cur_freq2 $cur_freq3`
	if [ $cur_freq != $max_freq ]
	then
		echo "core $i : conservative governor test failed !"
		ret=$(($ret+1))
	else
		echo "core $i : conservative governor test passed !"
	fi
	kill -9 $pid

####restore governors
	echo $saved_governors > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
	i=$(($i+1))
done

exit $ret

