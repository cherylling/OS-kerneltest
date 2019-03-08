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
	min_freq=`min $list_freq`

	saved_max=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq`
	saved_min=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq`

	echo $min_freq > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq
	ret=$(($ret+$?))
	echo $max_freq > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq
	ret=$(($re+$?))
#	echo "ondemand" > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
#	./cpu_load $i 50 &
#	pid=$!
	sleep 5
#	cur_freq=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq`

	if [ $ret = 0 ]
	then
		echo "core $i : scaling_max_freq and scaling_min_freq set ok unexpected !"
		ret=1
	else
		echo "core $i : scaling_max_freq and scaling_min_freq set NOTOK expected !"
		ret=0
	fi

	echo $saved_max > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq
	echo $saved_min > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq
####restore governors
	echo $saved_governors > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
#	kill -9 $pid
	i=$(($i+1))
done

exit $ret

