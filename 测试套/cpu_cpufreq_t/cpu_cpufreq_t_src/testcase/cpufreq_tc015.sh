#!/bin/bash

source ./cpufreq_conf.sh

cpu_num=`./cpu_num`
ret=0

i=1
while [ $i -lt $cpu_num ]
do
	saved_state=`cat /sys/devices/system/cpu/cpu$i/online`
	echo "online cpu $i"
	echo 1 > /sys/devices/system/cpu/cpu$i/online
	for file in $cpufreq_files
	do
		if [ ! -e /sys/devices/system/cpu/cpu$i/cpufreq/$file ]
		then
			echo "/sys/devices/system/cpu/cpu$i/cpufreq/$file is not exist !"
			ret=$(($ret+1))
		fi
	done	

	echo "offline cpu $i"
	echo 0 > /sys/devices/system/cpu/cpu$i/online
	for file in $cpufreq_files
	do
		if [ -e /sys/devices/system/cpu/cpu$i/cpufreq/$file ]
		then
			echo "/sys/devices/system/cpu/cpu$i/cpufreq/$file is exist"
			ret=$(($ret+1))
		fi
	done
	echo $saved_state > /sys/devices/system/cpu/cpu$i/online
	i=$(($i+1))
done

exit $ret

