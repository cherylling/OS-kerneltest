#!/bin/bash

source ./cpufreq_conf.sh

cpu_num=`./cpu_num`
ret=0

i=0
while [ $i -lt $cpu_num ]
do
	test_ret=0
	saved_governors=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor`
	saved_freq=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq`

	available_governrs=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_available_governors`
	avaliable_freqs=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_available_frequencies`
	setepeed_file=/sys/devices/system/cpu/cpu$i/cpufreq/scaling_setspeed

	test_freq=`min $avaliable_freqs`
	for governor in $available_governrs
	do
#		echo $governor
		if [ $governor != "userspace" ]
		then
			echo $test_freq > $setepeed_file
			test_ret=$(($test_ret + $?))
			
			echo "huiwegajks" > $setepeed_file
			test_ret=$(($test_ret + $?))

			echo $test_freq.00000 > $setepeed_file
			test_ret=$(($test_ret + $?))
		fi

	done
	if [ $test_ret -eq 0 ]
	then
		echo "cpu $i: test $setepeed_file failed !"
		ret=$(($ret+1))
	else
		echo "cpu $i : test $setepeed_file ok !"
	fi
	i=$(($i+1))
done

exit $ret

