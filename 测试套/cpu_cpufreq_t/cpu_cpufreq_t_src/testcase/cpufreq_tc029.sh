#!/bin/bash

source ./cpufreq_conf.sh

cpu_num=`./cpu_num`
ret=0

i=0
while [ $i -lt $cpu_num ]
do
	# save env
	saved_governors=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor`
	saved_scaling_setspeed=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_setspeed`
	saved_scaling_min_freq="`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq`"

	echo "userspace" > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
	scaling_min_freq="`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq`"
	set_value=$scaling_min_freq

	echo $set_value > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_setspeed

	sleep 1
	cur_freq=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq`
	if [ $cur_freq != $scaling_min_freq ]
	then
		echo "cpu $i : test failed !"
		ret=$(($ret+1))
	else
		echo "cpu $i : test passed !"
	fi

	#restore env
	echo $saved_governors > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
	echo $saved_scaling_setspeed > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_setspeed
	echo $saved_scaling_min_freq > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq

	i=$(($i+1))
done

exit $ret

