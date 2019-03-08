#!/bin/bash

source ./cpufreq_conf.sh
cpu_num=`./cpu_num`

ret=0
i=0
while [ $i -lt $cpu_num ]
do
	for file in $cpufreq_files
	do
		ls /sys/devices/system/cpu/cpu$i/cpufreq/$file > /dev/null
		if [ $? -ne 0 ]
		then
			echo "\"/sys/devices/system/cpu/cpu$i/cpufreq/$file\" is not exist !"
			ret=$(($ret + 1))
		fi
	done
	i=$(($i+1))
done

exit $ret
