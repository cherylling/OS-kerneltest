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
	saved_scaling_max_freq="`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq`"

	echo "ondemand" > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
	cpuinfo_max_freq=`cat /sys/devices/system/cpu/cpu$i/cpufreq/cpuinfo_max_freq`
	set_value=$(($cpuinfo_max_freq - 1))

	echo $set_value > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq

	sleep 1
	cur_freq=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq`

	if [ $cur_freq != $set_value ]
	then
		echo "<scaling_max_freq = $cur_freq> != <set_value=$set_value>"
		echo "cpu $i : test failed !"
		ret=$(($ret+1))
	else
		echo "cpu $i : test passed !"
	fi

	#restore env
	echo $saved_governors > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
	echo $saved_scaling_setspeed > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_setspeed
	echo $saved_scaling_max_freq > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq

	i=$(($i+1))
done

exit $ret

